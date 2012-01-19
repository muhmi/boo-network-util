namespace NetworkUtil

import System
import System.Net
import System.Net.Sockets
import System.Threading

class TcpClient(IClient):

	[Property(Socket)]
	_sock as Socket

	Id:
		get:
			return _id

	_id as string

	_sendPending = false

	def constructor(sock as Socket, _Id as string):
		_sock = sock
		_id = _Id

	def Write(buffer as (byte)):
		Write(buffer, 0, buffer.Length)

	def Write(buffer as (byte), offset, length):
		lock self:
			while _sendPending:
				Monitor.Wait(self, 1000)
		try:
			lock self:
				_sendPending = true
			_sock.BeginSend(buffer, offset, length, 0, AsyncCallback(WriteDone), _sock)
		except e:
			print e

	def WriteDone(ar as IAsyncResult):
		try:
			handler = ar.AsyncState as Socket
			handler.EndSend(ar)
		except e:
			print e
		ensure:
			lock self:
				_sendPending = false
				Monitor.Pulse(self)

	virtual def Close():
		try:
			lock self:
				while _sendPending:
					Monitor.Wait(self, 1000)
			_sock.Close()
		except e:
			print e


interface IClientEventHandler:
	def Connected(c as IClient)
	def Disconnected(c as IClient)
	def Receive(c as IClient, buffer as (byte), off as int, length as int)

class ReceivingTcpClient(TcpClient):

	_worker as Thread
	_buffer as (byte)
	_listener as IClientEventHandler

	def constructor(listener as IClientEventHandler, sock as Socket, _Id as string):
		super(sock, _Id)

		_listener = listener

		if _listener != null :
			_listener.Connected(self)

		_listener = listener
		_buffer = array(byte, 1024)
		_sock.BeginReceive(_buffer, 0, _buffer.Length, 0, AsyncCallback(ReadCallback), null)

	def ReadCallback(ar as IAsyncResult):

		read = _sock.EndReceive(ar)

		if read > 0:
			if _listener != null :
				_listener.Receive(self, _buffer, 0, read)
			_sock.BeginReceive(_buffer, 0, _buffer.Length, 0, AsyncCallback(ReadCallback), null)
		else:
			Close()

	override def Close():
		super.Close()
		if _listener != null :
			_listener.Disconnected(self)


static class TcpClientFactory:

	def Connect(hostname as string, port as int):
		return Connect(hostname, port, null)

	def Connect(hostname as string, port as int, listener as IClientEventHandler):
		ipHostInfo = Dns.GetHostEntry(hostname)
		remoteEP = IPEndPoint(ipHostInfo.AddressList[0], port)

		sock = Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp)
		sock.SetSocketOption(SocketOptionLevel.Tcp, SocketOptionName.NoDelay, true);
		sock.Connect(remoteEP)

		source = (sock.LocalEndPoint as IPEndPoint)

		return ReceivingTcpClient(listener, sock,  "$(source.Address):$(source.Port)")

