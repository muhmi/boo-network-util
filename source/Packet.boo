namespace NetworkUtil

import System.IO;


static class Packet:

	def Wrap(bytes as (byte)):
		using stream = MemoryStream(), writer = BinaryWriter(stream):
			writer.Write(bytes.Length cast int)
			writer.Write(bytes, 0, bytes.Length)
			return stream.ToArray()

	def UnWrap(stream as MemoryStream):
		using reader = BinaryReader(stream):

			size = reader.ReadInt32()

			if reader.BaseStream.Position + reader.BaseStream.Length < size:
				return null

			return reader.ReadBytes(size)

	def UnWrap(bytes as (byte)):
		using stream = MemoryStream(bytes):
			return UnWrap(stream)

	def UnWrap(bytes as (byte), off as int, length as int):
		using stream = MemoryStream(bytes, off, length):
			return UnWrap(stream)
