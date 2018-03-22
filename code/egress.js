function process() {
    while (IsConnected()) {
        var evt = ReadInput(3600);
        if (IsDisconnectEvent(evt)) {
            BreakBridge();
            break;
        }
        if (IsBreakBridgeEvent(evt)) {
            Disconnect();
            break;
        }
    }
}
exports.process = process;
