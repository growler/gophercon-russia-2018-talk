function Main()
   local err = AcceptCall()
   if err ~= nil then
      return
   end
   err = PlayFile("http://media/greeting.mp3")
   if err ~= nil then
      Disconnect()
      return
   end
   while IsConnected() do
      local evt = ReadInput(3600)
      if evt ~= nil and IsPlayFileCompletedEvent(evt) then
         break
      end
   end
end
