# Privacy Permissions for Agentic Personal Assistant

Add these keys to your Info.plist file:

## Location Services
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to provide weather information and find nearby places.</string>
```

## Notifications
Notifications are handled at runtime through NotificationService.

## App Transport Security (for API calls)
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
</dict>
```

## Instructions:
1. Open your project in Xcode
2. Select the target "Agentic Personal Assistant"
3. Go to the "Info" tab
4. Add these custom iOS target properties
5. Or edit Info.plist directly if using source code view
