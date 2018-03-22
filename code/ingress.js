var call = require('lib/call.js');
function Main() {
    var dest = PendingRequestData('To');
    ProvisionCall();
    StartBridge(Spawn('egress', dest));
    call.process();
}
function egress(dest) {
    var bridge = ReadInput();
    StartBridgedCall(dest, bridge);
    var evt = ReadInput(60);
    if (!IsCallCompletedEvent(evt)) {
        RejectBridge(bridge);
    }
    call.process();
}
