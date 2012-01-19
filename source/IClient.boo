namespace NetworkUtil

interface IClient:
	
	Id:
		get

	def Write(buffer as (byte))

	def Write(buffer as (byte), offset, length)

	def Close()

