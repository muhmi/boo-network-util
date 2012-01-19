import NetworkUtil

class EchoServer(IServerEventHandler):

	def OnConnect(client as IClient):
		print "S: Connected $(client.Id)"

	def OnDisconnect(client as IClient):
		print "S: Disconnect $(client.Id)"

	def OnReceive(client as IClient, buffer, offset, length):

		content = Packet.UnWrap(buffer, offset, length)

		if content != null:
			print "S: " + Message.Dump(Message.Decode(content))
			client.Write(buffer, offset, length)
		else:
			print "S: UnWrap failed, read sum more... to some buffer..."

class EchoClient(IClientEventHandler):

	def Connected(c as IClient):
		print "C: $(c.Id) connected"

	def Disconnected(c as IClient):
		print "C: $(c.Id) disconnected"

	def Receive(c as IClient, buffer as (byte), off as int, length as int):

		content = Packet.UnWrap(buffer, off, length)

		if content != null:
			msg = Message.Decode(content)
			print "C: $(c.Id) " + Message.Dump(msg)

		c.Close()

server = ServerSkeleton(EchoServer())
server.Start()

handler = EchoClient()

for i in range(0, 20):
	client = TcpClientFactory.Connect("localhost", 9000, handler)
	client.Write(Packet.Wrap(Message.Encode({"key": "Hello world!", "something": 1+i})))

prompt "Press enter to exit.\n"
print "bye."
server.Stop()
