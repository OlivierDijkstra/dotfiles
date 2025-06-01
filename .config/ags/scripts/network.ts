import AstalNetwork from "gi://AstalNetwork";
import { GObject, Variable, bind, execAsync } from "astal";

class NetworkService extends GObject.Object {
	static {
		GObject.registerClass(NetworkService);
	}

	#network = AstalNetwork.get_default();

	// Get the primary connection type
	get primary() {
		return this.#network.primary;
	}

	// Get WiFi interface
	get wifi() {
		return this.#network.wifi;
	}

	// Get wired interface
	get wired() {
		return this.#network.wired;
	}

	// Get connection status as a readable string
	get connectionStatus() {
		try {
			const primary = this.#network?.primary;

			if (primary === AstalNetwork.Primary.WIFI) {
				const wifi = this.#network?.wifi;
				if (!wifi) return "WiFi Unavailable";
				if (!wifi.enabled) return "Disabled";

				switch (wifi.internet) {
					case AstalNetwork.Internet.CONNECTED:
						return wifi.ssid || "Connected";
					case AstalNetwork.Internet.DISCONNECTED:
						return "Disconnected";
					case AstalNetwork.Internet.CONNECTING:
						return "Connecting...";
					default:
						return "Unknown";
				}
			}

			if (primary === AstalNetwork.Primary.WIRED) {
				const wired = this.#network?.wired;
				if (!wired) return "Ethernet Unavailable";

				switch (wired.internet) {
					case AstalNetwork.Internet.CONNECTED:
						return "Connected";
					case AstalNetwork.Internet.DISCONNECTED:
						return "Disconnected";
					case AstalNetwork.Internet.CONNECTING:
						return "Connecting...";
					default:
						return "Unknown";
				}
			}

			return "No Connection";
		} catch (error) {
			return "Network Error";
		}
	}

	// Get connection type as a readable string
	get connectionType() {
		try {
			const primary = this.#network?.primary;

			if (primary === AstalNetwork.Primary.WIFI) {
				return "WiFi";
			}

			if (primary === AstalNetwork.Primary.WIRED) {
				return "Ethernet";
			}

			return "Internet";
		} catch (error) {
			return "Internet";
		}
	}

	// Get appropriate icon for current connection
	get connectionIcon() {
		try {
			const primary = this.#network?.primary;

			if (primary === AstalNetwork.Primary.WIFI) {
				const wifi = this.#network?.wifi;
				if (!wifi) return "󰤮"; // WiFi unavailable
				if (!wifi.enabled) return "󰤮"; // WiFi disabled

				switch (wifi.internet) {
					case AstalNetwork.Internet.CONNECTED:
						return "󰤨"; // WiFi connected
					case AstalNetwork.Internet.DISCONNECTED:
						return "󰤯"; // WiFi disconnected
					case AstalNetwork.Internet.CONNECTING:
						return "󰤤"; // WiFi connecting
					default:
						return "󰤫"; // WiFi unknown
				}
			}

			if (primary === AstalNetwork.Primary.WIRED) {
				const wired = this.#network?.wired;
				if (!wired) return "󰲛"; // Ethernet unavailable

				switch (wired.internet) {
					case AstalNetwork.Internet.CONNECTED:
						return "󰛳"; // Ethernet connected
					case AstalNetwork.Internet.DISCONNECTED:
						return "󰲛"; // Ethernet disconnected
					default:
						return "󰛵"; // Ethernet unknown
				}
			}

			return "󰲛"; // No connection
		} catch (error) {
			return "󰲛"; // Default icon on error
		}
	}

	// Check if any connection is enabled/active
	get isConnected() {
		try {
			const primary = this.#network?.primary;

			if (primary === AstalNetwork.Primary.WIFI) {
				const wifi = this.#network?.wifi;
				return (
					wifi?.enabled && wifi?.internet === AstalNetwork.Internet.CONNECTED
				);
			}

			if (primary === AstalNetwork.Primary.WIRED) {
				const wired = this.#network?.wired;
				return wired?.internet === AstalNetwork.Internet.CONNECTED;
			}

			return false;
		} catch (error) {
			return false;
		}
	}

	// Toggle WiFi on/off
	toggleWifi() {
		const wifi = this.#network.wifi;
		if (wifi) {
			wifi.set_enabled(!wifi.enabled);
		}
	}

	// Toggle network on/off using NetworkManager
	async toggleNetwork() {
		try {
			const primary = this.#network.primary;

			if (primary === AstalNetwork.Primary.WIFI) {
				this.toggleWifi();
			} else {
				// For wired or general network toggle
				await execAsync("nmcli networking off");
				setTimeout(() => execAsync("nmcli networking on"), 1000);
			}
		} catch (error) {
			console.error("Failed to toggle network:", error);
		}
	}

	// Scan for WiFi networks
	scanWifi() {
		const wifi = this.#network.wifi;
		if (wifi?.enabled) {
			wifi.scan();
		}
	}

	static getDefault() {
		return new NetworkService();
	}
}

export { NetworkService };
