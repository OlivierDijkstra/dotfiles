import { Variable, bind } from "astal";
import { Astal, Gtk, Widget } from "astal/gtk3";
import { exec, execAsync } from "astal/process";
import { Wireplumber } from "../scripts/volume";
import { Windows } from "../scripts/windows";
import { Workspaces } from "./Workspaces";

const time = Variable("").poll(1000, () => {
	const now = new Date();
	const timeStr = now.toLocaleTimeString("en-US", {
		hour: "2-digit",
		minute: "2-digit",
		hour12: false,
	});
	const dateStr = now.toLocaleDateString("en-US", {
		weekday: "short",
		month: "short",
		day: "numeric",
	});
	return `${dateStr} • ${timeStr}`;
});

// Color picker state
const lastPickedColor = Variable("#FFFFFF");

function volumeIndicator() {
	const sink = Wireplumber.getDefault().getDefaultSink();

	return new Widget.EventBox({
		className: "button",
		onScroll: (_, event) => {
			if (event.delta_y > 0) {
				Wireplumber.getDefault().decreaseEndpointVolume(sink, 5);
			} else {
				Wireplumber.getDefault().increaseEndpointVolume(sink, 5);
			}
		},
		onClick: () => {
			Windows.toggle("control-panel");
		},
		child: new Widget.Box({
			spacing: 8,
			children: [
				new Widget.Label({
					label: bind(sink, "mute").as((muted) => (!muted ? "󰕾" : "󰖁")),
				}),
				new Widget.Label({
					label: bind(sink, "volume").as(
						(volume) => `${Math.floor(volume * 100)}%`,
					),
				}),
			],
		}),
	});
}

function colorPicker() {
	const pickColor = async () => {
		try {
			const output = await execAsync([
				"bash",
				"-c",
				"hyprpicker --format=hex --no-fancy --autocopy 2>/dev/null",
			]);

			// Extract hex color from output (look for #RRGGBB pattern)
			const hexMatch = output.match(/#[0-9A-Fa-f]{6}/);
			if (hexMatch) {
				const color = hexMatch[0];
				lastPickedColor.set(color);

				// Send notification
				execAsync([
					"notify-send",
					"Color Picked",
					`${color} copied to clipboard`,
					"--icon=applications-graphics",
				]).catch(() => {
					// Fallback if notify-send fails
					print(`Color picked: ${color}`);
				});
			}
		} catch (error) {
			print(`Color picker error: ${error}`);
		}
	};

	return new Widget.EventBox({
		className: "button",
		onClick: () => {
			pickColor();
		},
		child: new Widget.Box({
			spacing: 8,
			children: [
				new Widget.Box({
					className: "color-preview",
					widthRequest: 14,
					heightRequest: 14,
					valign: Gtk.Align.CENTER,
					halign: Gtk.Align.CENTER,
					expand: false,
					css: bind(lastPickedColor).as(
						(color) =>
							`background-color: ${color}; 
						 border-radius: 2px;`,
					),
				}),
				new Widget.Label({
					label: bind(lastPickedColor),
				}),
			],
		}),
	});
}

function screenshotTool() {
	const takeScreenshot = async () => {
		try {
			// Generate timestamp for filename
			const timestamp = new Date().toISOString().replace(/[:.]/g, "-");
			const filename = `/tmp/screenshot-${timestamp}.png`;

			// Use slurp to get region and grim to screenshot in one command
			await execAsync([
				"bash",
				"-c",
				`slurp | grim -g - "${filename}" && wl-copy --type image/png < "${filename}" 2>/dev/null`,
			]);

			// Send notification
			execAsync([
				"notify-send",
				"Screenshot Taken",
				"Screenshot saved and copied to clipboard",
			]).catch(() => {
				// Fallback if notify-send fails
				print(`Screenshot taken: ${filename}`);
			});
		} catch (error) {
			// User likely cancelled selection or tool not available
			print(`Screenshot cancelled or error: ${error}`);
		}
	};

	return new Widget.EventBox({
		className: "button",
		onClick: () => {
			takeScreenshot();
		},
		child: new Widget.Label({
			label: " 󰄀 ",
			className: "icon-fix",
		}),
	});
}

export default function Bar(mon: number) {
	return new Widget.Window({
		namespace: "finder-bar",
		anchor:
			Astal.WindowAnchor.TOP |
			Astal.WindowAnchor.LEFT |
			Astal.WindowAnchor.RIGHT,
		layer: Astal.Layer.TOP,
		exclusivity: Astal.Exclusivity.EXCLUSIVE,
		heightRequest: 44,
		monitor: mon,
		visible: true,
		canFocus: false,
		className: "Bar",
		child: new Widget.Box({
			className: "pill-bar",
			expand: true,
			homogeneous: false,
			child: new Widget.CenterBox({
				expand: true,
				homogeneous: false,
				startWidget: new Widget.Box({
					className: "left-section",
					halign: Gtk.Align.START,
					children: [Workspaces()],
				}),
				centerWidget: new Widget.Box({
					className: "center-section",
					halign: Gtk.Align.CENTER,
					children: [
						new Widget.Label({
							className: "time-label",
							label: bind(time),
						}),
					],
				}),
				endWidget: new Widget.Box({
					className: "right-section",
					halign: Gtk.Align.END,
					children: [screenshotTool(), colorPicker(), volumeIndicator()],
				}),
			}),
		}),
	});
}
