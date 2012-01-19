namespace NetworkUtil

import System.IO;


static class Packet:
	
	
	def Wrap(bytes as (byte)):
		using stream = MemoryStream(), writer = BinaryWriter(stream):
			writer.Write(bytes.Length cast int)
			writer.Write(bytes, 0, bytes.Length)
			writer.Close()
			return stream.ToArray()

	def UnWrap(stream as MemoryStream):
		
		using reader = BinaryReader(stream):
			
			size = reader.ReadInt32()
			
			if reader.BaseStream.Position + reader.BaseStream.Length < size:
				return null
			
			return reader.ReadBytes(size)

	def UnWrap(bytes as (byte)):
		using stream = MemoryStream(bytes):
			stream.Position = 0
			return UnWrap(stream)
