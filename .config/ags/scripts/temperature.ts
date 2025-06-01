import { GObject, property, register } from "astal";
import { exec, execAsync } from "astal/process";

export { TemperatureServiceClass as TemperatureService };

// Temperature range: 2000K (very warm) to 6500K (daylight)
const MIN_TEMP = 2000;
const MAX_TEMP = 6500;
const DEFAULT_TEMP = 6500;

@register({ GTypeName: "TemperatureService" })
class TemperatureServiceClass extends GObject.Object {
	private static inst: TemperatureServiceClass;

	private _temperature = DEFAULT_TEMP;
	private _enabled = true;
	private _isInitializing = true;

	@property(Number)
	get temperature(): number {
		return this._temperature;
	}

	@property(Boolean)
	get enabled(): boolean {
		return this._enabled;
	}

	static getDefault(): TemperatureServiceClass {
		if (!TemperatureServiceClass.inst) {
			TemperatureServiceClass.inst = new TemperatureServiceClass();
		}
		return TemperatureServiceClass.inst;
	}

	constructor() {
		super();
		this.loadSettings();
		// Mark initialization as complete after a short delay
		setTimeout(() => {
			this._isInitializing = false;
		}, 500);
	}

	private saveSettings() {
		const settings = {
			temperature: this._temperature,
			enabled: this._enabled,
		};

		try {
			execAsync([
				"bash",
				"-c",
				`mkdir -p ~/.config/ags && echo '${JSON.stringify(settings)}' > ~/.config/ags/temperature.json`,
			]);
		} catch (error) {
			console.error("Failed to save temperature settings:", error);
		}
	}

	private loadSettings() {
		try {
			const settingsJson = exec("cat ~/.config/ags/temperature.json");
			const settings = JSON.parse(settingsJson);

			if (
				settings.temperature &&
				settings.temperature >= MIN_TEMP &&
				settings.temperature <= MAX_TEMP
			) {
				this._temperature = settings.temperature;
			}

			if (typeof settings.enabled === "boolean") {
				this._enabled = settings.enabled;
			}
		} catch (error) {
			// Settings file doesn't exist or is invalid, use defaults
			console.log("Using default temperature settings");
		}
	}

	private async applyCurrentSettings() {
		try {
			if (this._enabled) {
				// Use hyprctl IPC to set temperature
				await execAsync([
					"hyprctl",
					"hyprsunset",
					"temperature",
					this._temperature.toString(),
				]);
			} else {
				// Use hyprctl IPC to disable color temperature
				await execAsync(["hyprctl", "hyprsunset", "identity"]);
			}
		} catch (error) {
			console.error("Failed to apply temperature settings via hyprctl:", error);
			console.log("Make sure hyprsunset is running as a daemon");
		}
	}

	async setTemperature(temp: number) {
		// Clamp temperature to valid range
		const clampedTemp = Math.max(
			MIN_TEMP,
			Math.min(MAX_TEMP, Math.round(temp)),
		);

		this._temperature = clampedTemp;
		this.notify("temperature");
		this.saveSettings();

		// Only apply settings if we're not initializing and the service is enabled
		if (!this._isInitializing && this._enabled) {
			await this.applyCurrentSettings();
		}
	}

	async toggleEnabled() {
		this._enabled = !this._enabled;
		this.notify("enabled");
		this.saveSettings();
		await this.applyCurrentSettings();
	}

	async setEnabled(enabled: boolean) {
		this._enabled = enabled;
		this.notify("enabled");
		this.saveSettings();
		await this.applyCurrentSettings();
	}

	// Helper methods for temperature ranges
	getTemperaturePercent(): number {
		return ((this._temperature - MIN_TEMP) / (MAX_TEMP - MIN_TEMP)) * 100;
	}

	setTemperatureFromPercent(percent: number) {
		const temp = MIN_TEMP + (percent / 100) * (MAX_TEMP - MIN_TEMP);
		this.setTemperature(temp);
	}

	getTemperatureLabel(): string {
		const temp = this._temperature;
		if (temp <= 2500) return "Very Warm";
		if (temp <= 3500) return "Warm";
		if (temp <= 4500) return "Neutral";
		if (temp <= 5500) return "Cool";
		return "Daylight";
	}

	// Constants for external use
	static get MIN_TEMP(): number {
		return MIN_TEMP;
	}

	static get MAX_TEMP(): number {
		return MAX_TEMP;
	}
}
