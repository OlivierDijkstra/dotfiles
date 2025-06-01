import { GObject, property, register } from "astal";
import { exec, execAsync } from "astal/process";

export { NotificationServiceClass as NotificationService };

@register({ GTypeName: "NotificationService" })
class NotificationServiceClass extends GObject.Object {
	private static inst: NotificationServiceClass;

	private _isDoNotDisturb = false;
	private _checkInterval: number | null = null;

	@property(Boolean)
	get isDoNotDisturb(): boolean {
		return this._isDoNotDisturb;
	}

	static getDefault(): NotificationServiceClass {
		if (!NotificationServiceClass.inst) {
			NotificationServiceClass.inst = new NotificationServiceClass();
		}
		return NotificationServiceClass.inst;
	}

	constructor() {
		super();
		this.checkStatus();
		this.startPolling();
	}

	private checkStatus(): void {
		try {
			// Check if mako is in do not disturb mode
			// We'll check if mako is running and not in a disabled state
			const result = exec("makoctl mode");
			const mode = result.trim();
			const wasDoNotDisturb = this._isDoNotDisturb;

			// Mako's "do-not-disturb" mode or "invisible" mode
			this._isDoNotDisturb = mode === "do-not-disturb" || mode === "invisible";

			if (wasDoNotDisturb !== this._isDoNotDisturb) {
				console.log(
					`Notification mode changed from ${wasDoNotDisturb} to ${this._isDoNotDisturb} (mode: ${mode})`,
				);
				this.notify("is-do-not-disturb");
			}
		} catch (error) {
			// If makoctl mode fails, assume DND is off
			const wasDoNotDisturb = this._isDoNotDisturb;
			this._isDoNotDisturb = false;

			if (wasDoNotDisturb !== this._isDoNotDisturb) {
				console.log(
					`Notification mode check failed, assuming DND is off: ${error}`,
				);
				this.notify("is-do-not-disturb");
			}
		}
	}

	private startPolling(): void {
		// Check status every 3 seconds
		this._checkInterval = setInterval(() => {
			this.checkStatus();
		}, 3000) as unknown as number;
	}

	async toggleDoNotDisturb(): Promise<void> {
		try {
			if (this._isDoNotDisturb) {
				// Turn off do not disturb mode (set to default mode)
				await execAsync("makoctl mode -s default");
			} else {
				// Turn on do not disturb mode
				await execAsync("makoctl mode -s do-not-disturb");
			}
			// Force an immediate status check
			setTimeout(() => this.checkStatus(), 500);
		} catch (error) {
			console.error("Failed to toggle Do Not Disturb:", error);
		}
	}

	async enableDoNotDisturb(): Promise<void> {
		try {
			await execAsync("makoctl mode -s do-not-disturb");
			setTimeout(() => this.checkStatus(), 500);
		} catch (error) {
			console.error("Failed to enable Do Not Disturb:", error);
		}
	}

	async disableDoNotDisturb(): Promise<void> {
		try {
			await execAsync("makoctl mode -s default");
			setTimeout(() => this.checkStatus(), 500);
		} catch (error) {
			console.error("Failed to disable Do Not Disturb:", error);
		}
	}

	async dismissAllNotifications(): Promise<void> {
		try {
			await execAsync("makoctl dismiss --all");
		} catch (error) {
			console.error("Failed to dismiss all notifications:", error);
		}
	}

	destroy(): void {
		if (this._checkInterval !== null) {
			clearInterval(this._checkInterval);
			this._checkInterval = null;
		}
		super.run_dispose();
	}
}
