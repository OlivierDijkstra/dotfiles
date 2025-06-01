import { GObject, property, register } from "astal";
import { exec, execAsync } from "astal/process";

export { DockerServiceClass as DockerService };

@register({ GTypeName: "DockerService" })
class DockerServiceClass extends GObject.Object {
	private static inst: DockerServiceClass;

	private _isRunning = false;
	private _checkInterval: number | null = null;

	@property(Boolean)
	get isRunning(): boolean {
		return this._isRunning;
	}

	static getDefault(): DockerServiceClass {
		if (!DockerServiceClass.inst) {
			DockerServiceClass.inst = new DockerServiceClass();
		}
		return DockerServiceClass.inst;
	}

	constructor() {
		super();
		this.checkStatus();
		this.startPolling();
	}

	private checkStatus(): void {
		try {
			// Use exec with proper error handling for systemctl states
			const result = exec("systemctl is-active docker");
			const status = result.trim();
			const wasRunning = this._isRunning;

			// Consider Docker running only when status is "active"
			this._isRunning = status === "active";

			console.log(
				`Docker status check: ${status} -> isRunning: ${this._isRunning}`,
			);
			if (wasRunning !== this._isRunning) {
				console.log(
					`Docker state changed from ${wasRunning} to ${this._isRunning}`,
				);
				this.notify("is-running");
			}
		} catch (error) {
			// systemctl returns non-zero exit codes for non-active states
			// This is expected behavior, not an error
			const wasRunning = this._isRunning;

			// Try to extract the status from the error output if possible
			let status = "unknown";
			try {
				// Get status using systemctl show which doesn't fail
				const showResult = exec(
					"systemctl show docker --property=ActiveState --value",
				);
				status = showResult.trim();
				this._isRunning = status === "active";
			} catch (showError) {
				// If even systemctl show fails, Docker is definitely not running
				this._isRunning = false;
				status = "unavailable";
			}

			console.log(
				`Docker status check (via show): ${status} -> isRunning: ${this._isRunning}`,
			);
			if (wasRunning !== this._isRunning) {
				console.log(
					`Docker state changed from ${wasRunning} to ${this._isRunning}`,
				);
				this.notify("is-running");
			}
		}
	}

	private startPolling(): void {
		// Check status every 5 seconds
		this._checkInterval = setInterval(() => {
			this.checkStatus();
		}, 5000) as unknown as number;
	}

	async toggleDocker(): Promise<void> {
		try {
			if (this._isRunning) {
				await execAsync("systemctl stop docker");
			} else {
				await execAsync("systemctl start docker");
			}
			// Force an immediate status check
			setTimeout(() => this.checkStatus(), 1000);
		} catch (error) {
			console.error("Failed to toggle Docker:", error);
		}
	}

	async startDocker(): Promise<void> {
		try {
			await execAsync("systemctl start docker");
			setTimeout(() => this.checkStatus(), 1000);
		} catch (error) {
			console.error("Failed to start Docker:", error);
		}
	}

	async stopDocker(): Promise<void> {
		try {
			await execAsync("systemctl stop docker");
			setTimeout(() => this.checkStatus(), 1000);
		} catch (error) {
			console.error("Failed to stop Docker:", error);
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
