local Compression = {};

function Compression.Compress(x)   return x end
function Compression.Decompress(x) return x end

return table.freeze(Compression) :: {
	Compress: (number) -> number,
	Decompress: (number) -> number,
}