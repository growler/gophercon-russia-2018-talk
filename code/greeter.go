func Greet(runtime app.TaskRuntime, evtChan <-chan *app.TaskEvent, params ...interface{}) interface{} {
	r := runtime.(app.SignalTaskRuntime)
	if err := r.AcceptCall(); err != nil {
		return err
	}
	if err := r.PlayFile("http://media/greeting.mp3", false); err != nil {
		return err
	}
	for r.IsConnected() {
		evt := <-evtChan
		if r.IsPlayFileCompletedEvent(evt) {
			break
		}
	}
	return nil
}
