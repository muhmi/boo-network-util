import NetworkUtil

class EchoServer(IServerEventHandler):

	def OnConnect(client as IClient):
		print "S: Connected $(client.Id)"

	def OnDisconnect(client as IClient):
		print "S: Disconnect $(client.Id)"

	def OnReceive(client as IClient, buffer, offset, length):
		print "S: " + Message.Dump(Message.Decode(buffer, offset, length))
		client.Write(buffer, offset, length)

class EchoClient(IClientEventHandler):

	def Connected(c as IClient):
		print "C: $(c.Id) connected"

	def Disconnected(c as IClient):
		print "C: $(c.Id) disconnected"

	def Receive(c as IClient, buffer as (byte), off as int, length as int):
		print "C: $(c.Id) " + Message.Dump(Message.Decode(buffer, off, length))
		c.Close()

server = ServerSkeleton(EchoServer())
server.Start()

handler = EchoClient()

for i in range(0, 5):
	print "start client #$(1+i)"
	client = TcpClientFactory.Connect("localhost", 9000, handler)
	client.Write(Message.Encode({"key": "Hello world!", "something": 1+i}))

prompt "Press enter to exit.\n"
print "bye."
server.Stop()
