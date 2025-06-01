import AstalWp from "gi://AstalWp";
import { GObject, register } from "astal";

export { WireplumberClass as Wireplumber };

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
}
