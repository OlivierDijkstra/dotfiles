import AstalBluetooth from "gi://AstalBluetooth";
import AstalNetwork from "gi://AstalNetwork";
import { type GObject, Variable, bind, execAsync } from "astal";
import { Astal, Gtk, Widget } from "astal/gtk3";
import { DockerService } from "../scripts/docker";
import { NotificationService } from "../scripts/notification";
import { RecordingService } from "../scripts/recording";
import { Wireplumber } from "../scripts/volume";
import { PopupWindow, type PopupWindowProps } from "./PopupWindow";
import { DynamicServiceButton, ServiceButton } from "./ServiceButton";

export const ControlPanel = (mon: number) =>
	PopupWindow({
		namespace: "control-panel",
		className: "control-panel",
		halign: Gtk.Align.END,
		valign: Gtk.Align.START,
		layer: Astal.Layer.OVERLAY,
		marginRight: 10,
		monitor: mon,
		widthRequest: 400,
		child: new Widget.Box({
			className: "control-panel-container",
			orientation: Gtk.Orientation.VERTICAL,
			spacing: 12,
			children: [
				// Volume section
				new Widget.Box({
					className: "control-row",
					spacing: 6,
					children: (() => {
						const sink = Wireplumber.getDefault().getDefaultSink();
						return [
							new Widget.Button({
								className: "control-button",
								label: bind(sink, "mute").as((muted) => (!muted ? "󰕾" : "󰖁")),
								onClick: () => Wireplumber.getDefault().toggleMuteSink(),
							} as Widget.ButtonProps),
							new Widget.Slider({
								className: "control-slider",
								drawValue: false,
								hexpand: true,
								setup: (slider) => {
									slider.value = Math.floor(sink.volume * 100);
								},
								value: bind(sink, "volume").as((vol) => Math.floor(vol * 100)),
								max: 100,
								onDragged: (slider) => sink.set_volume(slider.value / 100),
							} as Widget.SliderProps),
						];
					})(),
				}),
				// Microphone section
				new Widget.Box({
					className: "control-row",
					spacing: 6,
					children: (() => {
						const source = Wireplumber.getDefault().getDefaultSource();
						return [
							new Widget.Button({
								className: "control-button",
								label: bind(source, "mute").as((muted) => (!muted ? "󰍬" : "󰍭")),
								onClick: () => Wireplumber.getDefault().toggleMuteSource(),
							} as Widget.ButtonProps),
							new Widget.Slider({
								className: "control-slider",
								drawValue: false,
								hexpand: true,
								setup: (slider) => {
									slider.value = Math.floor(source.volume * 100);
								},
								value: bind(source, "volume").as((vol) =>
									Math.floor(vol * 100),
								),
								max: 100,
								onDragged: (slider) => source.set_volume(slider.value / 100),
							} as Widget.SliderProps),
						];
					})(),
				}),
				// Compact actions row
				new Widget.Box({
					className: "compact-actions-row",
					spacing: 8,
					halign: Gtk.Align.START,
					children: [
						// Screen Recording compact button
						new Widget.Button({
							className: Variable.derive(
								[
									bind(RecordingService.getDefault(), "recording"),
									bind(RecordingService.getDefault(), "recordingType"),
								],
								(recording: boolean, recordingType: string | null) => {
									if (recording && recordingType === "fullscreen")
										return "compact-service-button enabled";
									if (recording && recordingType === "region")
										return "compact-service-button disabled";
									return "compact-service-button disabled";
								},
							)(),
							onClick: () => RecordingService.getDefault().toggleRecording(),
							tooltipText: Variable.derive(
								[
									bind(RecordingService.getDefault(), "recording"),
									bind(RecordingService.getDefault(), "recordingType"),
								],
								(recording: boolean, recordingType: string | null) => {
									if (recording && recordingType === "fullscreen")
										return "Stop Full Screen Recording";
									if (recording && recordingType === "region")
										return "Region recording active";
									return "Start Full Screen Recording";
								},
							)(),
							child: new Widget.Label({
								label: "󰻂",
								className: "compact-service-icon icon-fix",
								halign: Gtk.Align.CENTER,
								valign: Gtk.Align.CENTER,
							}),
						} as Widget.ButtonProps),
						// Region Recording compact button
						new Widget.Button({
							className: Variable.derive(
								[
									bind(RecordingService.getDefault(), "recording"),
									bind(RecordingService.getDefault(), "recordingType"),
								],
								(recording: boolean, recordingType: string | null) => {
									if (recording && recordingType === "region")
										return "compact-service-button enabled";
									if (recording && recordingType === "fullscreen")
										return "compact-service-button disabled";
									return "compact-service-button disabled";
								},
							)(),
							onClick: () =>
								RecordingService.getDefault().startRegionRecording(),
							tooltipText: Variable.derive(
								[
									bind(RecordingService.getDefault(), "recording"),
									bind(RecordingService.getDefault(), "recordingType"),
								],
								(recording: boolean, recordingType: string | null) => {
									if (recording && recordingType === "region")
										return "Stop Region Recording";
									if (recording && recordingType === "fullscreen")
										return "Full screen recording active";
									return "Select Region to Record";
								},
							)(),
							child: new Widget.Label({
								label: "󰩭",
								className: "compact-service-icon",
								halign: Gtk.Align.CENTER,
								valign: Gtk.Align.CENTER,
							}),
						} as Widget.ButtonProps),
					],
				}),
				// Services section - First row
				new Widget.Box({
					className: "control-row",
					spacing: 6,
					homogeneous: true,
					children: [
						// Docker Service Button - using DynamicServiceButton
						DynamicServiceButton(
							"󰡨", // Docker icon
							"Docker",
							DockerService.getDefault(),
							"isRunning",
							(running) => (running ? "Running" : "Stopped"),
							() => DockerService.getDefault().toggleDocker(),
						),
						// Bluetooth service button - dynamic with real functionality
						(() => {
							const bluetooth = AstalBluetooth.get_default();

							// Helper functions for Bluetooth state
							const getBluetoothIcon = (
								isPowered: boolean,
								isConnected: boolean,
								hasAdapter: boolean,
							) => {
								if (!hasAdapter) return "󰂲"; // No adapter
								if (!isPowered) return "󰂲"; // Powered off
								if (isConnected) return "󰂱"; // Connected
								return "󰂯"; // Powered on but not connected
							};

							const getBluetoothStatus = (
								isPowered: boolean,
								isConnected: boolean,
								hasAdapter: boolean,
								devices: AstalBluetooth.Device[],
							) => {
								if (!hasAdapter) return "No Adapter";
								if (!isPowered) return "Disabled";

								const connectedDevices = devices.filter((dev) => dev.connected);
								if (connectedDevices.length > 0) {
									if (connectedDevices.length === 1) {
										return connectedDevices[0].alias || "Connected";
									}
									return `${connectedDevices.length} Connected`;
								}

								return "Ready";
							};

							return new Widget.Button({
								className: bind(bluetooth, "isPowered").as(
									(isPowered: boolean) =>
										`pill-service-button ${isPowered ? "enabled" : "disabled"}`,
								),
								// Always show the button, even if no adapter
								onClick: () => {
									// Toggle Bluetooth power
									if (bluetooth.adapter) {
										bluetooth.adapter.set_powered(!bluetooth.isPowered);
									}
								},
								tooltipText: "Click to toggle Bluetooth",
								child: new Widget.Box({
									orientation: Gtk.Orientation.HORIZONTAL,
									spacing: 20,
									halign: Gtk.Align.FILL,
									children: [
										new Widget.Label({
											label: Variable.derive(
												[
													bind(bluetooth, "isPowered"),
													bind(bluetooth, "isConnected"),
												],
												(isPowered: boolean, isConnected: boolean) =>
													getBluetoothIcon(
														isPowered,
														isConnected,
														Boolean(bluetooth.adapter),
													),
											)(),
											className: "service-icon",
											halign: Gtk.Align.CENTER,
											valign: Gtk.Align.CENTER,
										}),
										new Widget.Box({
											orientation: Gtk.Orientation.VERTICAL,
											spacing: 2,
											halign: Gtk.Align.START,
											valign: Gtk.Align.CENTER,
											hexpand: true,
											children: [
												new Widget.Label({
													label: "Bluetooth",
													className: "service-title",
													halign: Gtk.Align.START,
													valign: Gtk.Align.CENTER,
												}),
												new Widget.Label({
													label: Variable.derive(
														[
															bind(bluetooth, "isPowered"),
															bind(bluetooth, "isConnected"),
															bind(bluetooth, "devices"),
														],
														(
															isPowered: boolean,
															isConnected: boolean,
															devices: AstalBluetooth.Device[],
														) =>
															getBluetoothStatus(
																isPowered,
																isConnected,
																Boolean(bluetooth.adapter),
																devices,
															),
													)(),
													className: "service-status",
													halign: Gtk.Align.START,
													valign: Gtk.Align.CENTER,
												}),
											],
										}),
									],
								}),
							} as Widget.ButtonProps);
						})(),
					],
				}),
				// Services section - Second row
				new Widget.Box({
					className: "control-row",
					spacing: 6,
					homogeneous: true,
					children: [
						// Network service button - dynamically detects WiFi/Ethernet
						(() => {
							const network = AstalNetwork.get_default();

							// Helper functions for network state
							const getConnectionIcon = (
								primary: AstalNetwork.Primary,
								wifi: AstalNetwork.Wifi | null,
								wired: AstalNetwork.Wired | null,
							) => {
								if (primary === AstalNetwork.Primary.WIFI) {
									if (!wifi?.enabled) return "󰤮";
									switch (wifi?.internet) {
										case AstalNetwork.Internet.CONNECTED:
											return "󰤨";
										case AstalNetwork.Internet.DISCONNECTED:
											return "󰤯";
										case AstalNetwork.Internet.CONNECTING:
											return "󰤤";
										default:
											return "󰤫";
									}
								}
								if (primary === AstalNetwork.Primary.WIRED) {
									switch (wired?.internet) {
										case AstalNetwork.Internet.CONNECTED:
											return "󰛳";
										case AstalNetwork.Internet.DISCONNECTED:
											return "󰲛";
										default:
											return "󰛵";
									}
								}
								return "󰲛";
							};

							const getConnectionType = (primary: AstalNetwork.Primary) => {
								if (primary === AstalNetwork.Primary.WIFI) return "WiFi";
								if (primary === AstalNetwork.Primary.WIRED) return "Ethernet";
								return "Internet";
							};

							const getConnectionStatus = (
								primary: AstalNetwork.Primary,
								wifi: AstalNetwork.Wifi | null,
								wired: AstalNetwork.Wired | null,
							) => {
								if (primary === AstalNetwork.Primary.WIFI) {
									if (!wifi?.enabled) return "Disabled";
									switch (wifi?.internet) {
										case AstalNetwork.Internet.CONNECTED:
											return wifi?.ssid || "Connected";
										case AstalNetwork.Internet.DISCONNECTED:
											return "Disconnected";
										case AstalNetwork.Internet.CONNECTING:
											return "Connecting...";
										default:
											return "Unknown";
									}
								}
								if (primary === AstalNetwork.Primary.WIRED) {
									switch (wired?.internet) {
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
							};

							const isConnected = (
								primary: AstalNetwork.Primary,
								wifi: AstalNetwork.Wifi | null,
								wired: AstalNetwork.Wired | null,
							) => {
								if (primary === AstalNetwork.Primary.WIFI) {
									return (
										wifi?.enabled &&
										wifi?.internet === AstalNetwork.Internet.CONNECTED
									);
								}
								if (primary === AstalNetwork.Primary.WIRED) {
									return wired?.internet === AstalNetwork.Internet.CONNECTED;
								}
								return false;
							};

							return new Widget.Button({
								className: bind(network, "primary").as(
									(primary: AstalNetwork.Primary) =>
										`pill-service-button ${isConnected(primary, network.wifi, network.wired) ? "enabled" : "disabled"}`,
								),
								onClick: () => {
									// Click: toggle connection
									if (network.primary === AstalNetwork.Primary.WIFI) {
										network.wifi?.set_enabled(!network.wifi?.enabled);
									} else if (network.primary === AstalNetwork.Primary.WIRED) {
										// Toggle networking for ethernet
										execAsync("nmcli networking off")
											.then(() => {
												setTimeout(
													() => execAsync("nmcli networking on"),
													1000,
												);
											})
											.catch(() => {
												// If turning off fails, try turning on
												execAsync("nmcli networking on");
											});
									}
								},
								tooltipText: "Click to toggle connection",
								child: new Widget.Box({
									orientation: Gtk.Orientation.HORIZONTAL,
									spacing: 20,
									halign: Gtk.Align.FILL,
									children: [
										new Widget.Label({
											label: bind(network, "primary").as(
												(primary: AstalNetwork.Primary) =>
													getConnectionIcon(
														primary,
														network.wifi,
														network.wired,
													),
											),
											className: "service-icon",
											halign: Gtk.Align.CENTER,
											valign: Gtk.Align.CENTER,
										}),
										new Widget.Box({
											orientation: Gtk.Orientation.VERTICAL,
											spacing: 2,
											halign: Gtk.Align.START,
											valign: Gtk.Align.CENTER,
											hexpand: true,
											children: [
												new Widget.Label({
													label: bind(network, "primary").as(getConnectionType),
													className: "service-title",
													halign: Gtk.Align.START,
													valign: Gtk.Align.CENTER,
												}),
												new Widget.Label({
													label: bind(network, "primary").as(
														(primary: AstalNetwork.Primary) =>
															getConnectionStatus(
																primary,
																network.wifi,
																network.wired,
															),
													),
													className: "service-status",
													halign: Gtk.Align.START,
													valign: Gtk.Align.CENTER,
												}),
											],
										}),
									],
								}),
							} as Widget.ButtonProps);
						})(),
						// Do Not Disturb service button - using DynamicServiceButton
						DynamicServiceButton(
							"󰂛", // Do not disturb icon
							"Focus",
							NotificationService.getDefault(),
							"isDoNotDisturb",
							(dnd) => (dnd ? "On" : "Off"),
							() => NotificationService.getDefault().toggleDoNotDisturb(),
						),
					],
				}),
			],
		} as Widget.BoxProps),
	} as PopupWindowProps);
