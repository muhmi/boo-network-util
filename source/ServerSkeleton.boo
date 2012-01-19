namespace NetworkUtil

import System
import System.Net
import System.Net.Sockets
import System.Threading

class StateObject:
	public client as IClient
	public socket as Socket
	public buffer as (byte)

	def constructor(_socket as Socket, _client as IClient):
		client = _client
		socket = _socket
		buffer = array(byte, 1024)

class ServerSkeleton:

	[Property(ListenAddress, ListenAddress is not null)]
	_listenAddress = 'localhost'

	[Property(ListenPort)]
	_listenPort = 9000

	_listener as Socket

	_worker as Thread
	_alive = false

	_waitForConnection = ManualResetEvent(false)

	_handler as IServerEventHandler

	def constructor(handler as IServerEventHandler):
		_handler = handler;

	def Start():
		print "Listening at $(_listenAddress):$(_listenPort)"
		_worker = Thread(Worker)
		_worker.Start()

	def Stop():
		if _alive:
			_alive = false
			_waitForConnection.Set()
			_worker.Join()

	def Worker():

		ipAddress = IPAddress.Any

		if _listenAddress != 'localhost':
			ipAddress = Dns.GetHostEntry(_listenAddress).AddressList[0]

		endPoint = IPEndPoint(ipAddress, _listenPort)

		_listener = Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp );
		_listener.SetSocketOption(SocketOptionLevel.Tcp, SocketOptionName.NoDelay, true);
		_listener.SetSocketOption(SocketOptionLevel.Socket, SocketOptionName.DontLinger, true);

		_listener.Bind(endPoint);
		_listener.Listen(10);

		_alive = true

		while _alive:
			_waitForConnection.Reset()
			_listener.BeginAccept(AsyncCallback(AcceptCallback), _listener);
			_waitForConnection.WaitOne()

		_alive = false

	def AcceptCallback(ar as IAsyncResult):
		socket = _listener.EndAccept(ar)
		source = (socket.RemoteEndPoint as IPEndPoint)

		client = TcpClient(socket, "$(source.Address):$(source.Port)")

		_handler.OnConnect(client)

		_waitForConnection.Set()

		state = StateObject(socket, client)
		socket.BeginReceive(state.buffer, 0, state.buffer.Length, 0, AsyncCallback(ReadCallback), state)

	def ReadCallback(ar as IAsyncResult):
		state = ar.AsyncState cast StateObject
		bytesRead = state.socket.EndReceive(ar)

		if bytesRead > 0:
			_handler.OnReceive(state.client, state.buffer, 0, bytesRead)
			state.socket.BeginReceive(state.buffer, 0, state.buffer.Length, 0, AsyncCallback(ReadCallback), state)
		else:
			_handler.OnDisconnect(state.client)

