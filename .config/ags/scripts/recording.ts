import { GLib, GObject, Gio, execAsync } from "astal";
import { property, register, signal } from "astal/gobject";
import type { Gdk } from "astal/gtk3";

export { RecordingService };

@register({ GTypeName: "RecordingService" })
class RecordingService extends GObject.Object {
	private static instance: RecordingService;

	@signal()
	declare started: () => void;
	@signal()
	declare stopped: () => void;

	#recording = false;
	#recordingType: "fullscreen" | "region" | null = null;
	#path = "~/Recordings";

	/** Default extension: mp4(h264) */
	#extension = "mp4";
	#recordAudio = false;
	#area: Gdk.Rectangle | null = null;
	#startedAt: GLib.DateTime | null = null;
	#process: Gio.Subprocess | null = null;
	#output: string | null = null;

	@property()
	/** GLib.DateTime of when recording started */
	public get startedAt() {
		return this.#startedAt;
	}

	@property(Boolean)
	public get recording() {
		return this.#recording;
	}

	@property(String)
	public get recordingType() {
		return this.#recordingType || "";
	}
	public set recordingType(newValue: string | null) {
		this.#recordingType = newValue as "fullscreen" | "region" | null;
		this.notify("recordingType");
	}

	public set recording(newValue: boolean) {
		if (!newValue && this.#recording) {
			this.stopRecording();
		} else if (newValue && !this.#recording) {
			this.startRecording(this.#area || undefined);
		}

		this.#recording = newValue;
		this.notify("recording");
	}

	@property(String)
	public get path() {
		return this.#path;
	}
	public set path(newPath: string) {
		if (this.recording) return;

		this.#path = newPath;
		this.notify("path");
	}

	@property(String)
	public get extension() {
		return this.#extension;
	}
	public set extension(newExt: string) {
		if (this.recording) return;

		this.#extension = newExt;
		this.notify("extension");
	}

	/** Recording output file name. null if screen is not being recorded */
	public get output() {
		return this.#output;
	}

	/** Currently unsupported property */
	public get recordAudio() {
		return this.#recordAudio;
	}
	public set recordAudio(newValue: boolean) {
		if (this.recording) return;

		this.#recordAudio = newValue;
		this.notify("record-audio");
	}

	constructor() {
		super();
		const videosDir = GLib.get_user_special_dir(
			GLib.UserDirectory.DIRECTORY_VIDEOS,
		);
		if (videosDir) this.#path = `${videosDir}/Recordings`;
	}

	public static getDefault() {
		if (!RecordingService.instance)
			RecordingService.instance = new RecordingService();

		return RecordingService.instance;
	}

	private getDateTime() {
		return GLib.DateTime.new_now_local();
	}

	private makeDirectory(path: string) {
		try {
			const file = Gio.File.new_for_path(path);
			file.make_directory_with_parents(null);
		} catch (error) {
			// Directory might already exist, that's okay
		}
	}

	public startRecording(area?: Gdk.Rectangle) {
		if (this.recording) throw new Error("Screen Recording is already running!");

		this.#output = `${this.getDateTime().format("%Y-%m-%d-%H%M%S")}_rec.${this.extension || "mp4"}`;
		this.#recording = true;
		this.recordingType = area ? "region" : "fullscreen";
		this.notify("recording");
		this.emit("started");
		this.makeDirectory(this.path);

		const cancellable = Gio.Cancellable.new();
		cancellable.cancel = () => {};

		const areaString = `${area?.x ?? 0},${area?.y ?? 0} ${area?.width ?? 1}x${area?.height ?? 1}`;

		const outputPath = this.#output;
		if (!outputPath) return;

		this.#process = Gio.Subprocess.new(
			[
				"wf-recorder",
				...(area ? ["-g", areaString] : []),
				"-f",
				`${this.path}/${outputPath}`,
			],
			Gio.SubprocessFlags.STDOUT_PIPE | Gio.SubprocessFlags.STDERR_PIPE,
		);

		this.#process.wait_async(cancellable, () => {
			this.stopRecording();
		});

		this.#startedAt = this.getDateTime();
	}

	public stopRecording() {
		if (!this.#process) return;

		try {
			if (!this.#process.get_if_exited()) {
				const processId = this.#process.get_identifier();
				if (processId) {
					execAsync(["kill", "-s", "SIGTERM", processId]).catch(() => {
						// Process might already be dead, that's ok
					});
				}
			}
		} catch (error) {
			// Process might already be cleaned up, continue with cleanup
		}

		const path = this.#path;
		const output = this.#output;

		this.#process = null;
		this.#recording = false;
		this.recordingType = null;
		this.#startedAt = null;
		this.#output = null;
		this.notify("recording");
		this.emit("stopped");

		// Send notification about recording completion
		execAsync([
			"notify-send",
			"Screen Recording",
			`Recording saved as ${path}/${output}`,
			"-t",
			"5000",
		]).catch(() => {
			// Fallback if notify-send is not available
			console.log(`Recording saved as ${path}/${output}`);
		});
	}

	public toggleRecording() {
		if (this.recording) {
			this.stopRecording();
		} else {
			this.startRecording();
		}
	}

	public async startRegionRecording() {
		if (this.recording) {
			// If already recording, stop it instead
			this.stopRecording();
			return;
		}

		try {
			// Use slurp to get region selection
			const regionOutput = await execAsync(["slurp"]);
			const region = regionOutput.trim();

			// Only start recording if a region was selected (slurp wasn't canceled)
			if (region) {
				// Parse the slurp output format: "x,y widthxheight"
				const [position, dimensions] = region.split(" ");
				const [x, y] = position.split(",").map(Number);
				const [width, height] = dimensions.split("x").map(Number);

				// Create a simple area object
				const areaRect = { x, y, width, height };
				this.startRecording(areaRect as Gdk.Rectangle);
			}
		} catch (error) {
			// User cancelled slurp or slurp failed
			console.log("Region selection cancelled or failed");
		}
	}
}
