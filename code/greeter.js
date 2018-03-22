function Main() {
    AcceptCall();
    PlayFile('http://media/greeting.mp3');
    while (IsConnected()) {
        var evt = ReadInput(3600);
        if (IsDisconnectEvent(evt)) {
            break;
        }
    }
}
