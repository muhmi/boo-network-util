namespace NetworkUtil

interface IServerEventHandler:

	def OnConnect(client as IClient)

	def OnDisconnect(client as IClient)

	def OnReceive(client as IClient, buffer, offset, length)

