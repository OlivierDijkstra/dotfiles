import AstalWp from "gi://AstalWp";
import { GObject, register } from "astal";

export { WireplumberClass as Wireplumber };

// Define interfaces for Wireplumber nodes
interface WireplumberNode {
	media_class?: number;
	"media-class"?: number;
	path?: string;
	direction?: number;
	id?: number;
	description?: string;
	set_default?: () => void;
}

interface WireplumberSink extends WireplumberNode {
	// Additional sink-specific properties
}

interface WireplumberSource extends WireplumberNode {
	// Additional source-specific properties
}

@register({ GTypeName: "Wireplumber" })
class WireplumberClass extends GObject.Object {
	private static astalWireplumber: AstalWp.Wp | null = AstalWp.get_default();
	private static inst: WireplumberClass;
	private defaultSink: AstalWp.Endpoint | null =
		WireplumberClass.astalWireplumber?.get_default_speaker() ?? null;
	private defaultSource: AstalWp.Endpoint | null =
		WireplumberClass.astalWireplumber?.get_default_microphone() ?? null;

	constructor() {
		super();

		if (!WireplumberClass.astalWireplumber)
			throw new Error(
				"Audio features will not work correctly! Please install wireplumber first",
				{
					cause: "Wireplumber library not found",
				},
			);
	}

	public static getDefault(): WireplumberClass {
		if (!WireplumberClass.inst) WireplumberClass.inst = new WireplumberClass();

		return WireplumberClass.inst;
	}
	public static getWireplumber(): AstalWp.Wp {
		if (!WireplumberClass.astalWireplumber) {
			throw new Error("Wireplumber not initialized");
		}
		return WireplumberClass.astalWireplumber;
	}

	public getDefaultSink(): AstalWp.Endpoint {
		if (!this.defaultSink) {
			throw new Error("Default sink not found");
		}
		return this.defaultSink;
	}

	public getDefaultSource(): AstalWp.Endpoint {
		if (!this.defaultSource) {
			throw new Error("Default source not found");
		}
		return this.defaultSource;
	}

	public get sinks(): WireplumberSink[] {
		if (!WireplumberClass.astalWireplumber) return [];
		const nodes = Array.from(
			WireplumberClass.astalWireplumber.get_nodes?.() || [],
		);
		// Only output devices: media_class === 2 or path contains 'playback'
		return nodes.filter((node: WireplumberNode) => {
			if (typeof node.media_class !== "undefined") {
				return node.media_class === 2;
			}
			if (typeof node["media-class"] !== "undefined") {
				return node["media-class"] === 2;
			}
			if (typeof node.path === "string") {
				return node.path.includes("playback");
			}
			return false;
		});
	}

	public get sources(): WireplumberSource[] {
		if (!WireplumberClass.astalWireplumber) return [];
		const nodes = Array.from(
			WireplumberClass.astalWireplumber.get_nodes?.() || [],
		);
		const sources = nodes.filter((n: WireplumberNode) => n.direction === 0);
		return sources;
	}

	public getSinkVolume(): number {
		return Math.floor(this.getDefaultSink().get_volume() * 100);
	}

	public getSourceVolume(): number {
		return Math.floor(this.getDefaultSource().get_volume() * 100);
	}

	public increaseEndpointVolume(
		endpoint: AstalWp.Endpoint,
		volumeIncrease: number,
	): void {
		const increase = Math.abs(volumeIncrease) / 100;

		if (endpoint.get_volume() + increase > 1.0) {
			endpoint.set_volume(1.0);
			return;
		}

		endpoint.set_volume(endpoint.get_volume() + increase);
	}

	public decreaseEndpointVolume(
		endpoint: AstalWp.Endpoint,
		volumeDecrease: number,
	): void {
		const decrease = Math.abs(volumeDecrease) / 100;

		if (endpoint.get_volume() - decrease < 0) {
			endpoint.set_volume(0);
			return;
		}

		endpoint.set_volume(endpoint.get_volume() - decrease);
	}

	public isMutedSink(): boolean {
		return this.getDefaultSink().get_mute();
	}

	public isMutedSource(): boolean {
		return this.getDefaultSource().get_mute();
	}

	public toggleMuteSink(): void {
		const sink = this.getDefaultSink();
		sink.set_mute(!sink.get_mute());
	}

	public toggleMuteSource(): void {
		const source = this.getDefaultSource();
		source.set_mute(!source.get_mute());
	}

	// Returns an array of all available output endpoints (sinks)
	public getAllSinks(): WireplumberSink[] {
		return this.sinks;
	}

	// Sets the default output endpoint (sink) by object
	public setDefaultSink(sink: WireplumberSink): void {
		if (!WireplumberClass.astalWireplumber) return;
		// Try to set the default sink using the endpoint's set_default method if available
		if (typeof sink.set_default === "function") {
			sink.set_default();
			this.defaultSink = sink as unknown as AstalWp.Endpoint;
		}
	}
}
