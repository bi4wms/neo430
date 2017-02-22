-- NEO430 Processor, by Stephan Nolting
-- Auto-generated memory init file (for APPLICATION)

library ieee;
use ieee.std_logic_1164.all;

package neo430_application_image is

  type application_init_image_t is array (0 to (2**16)-1) of std_ulogic_vector(15 downto 0);
  constant application_init_image : application_init_image_t := (
    000000 => x"4303",
    000001 => x"4218",
    000002 => x"ffe8",
    000003 => x"4211",
    000004 => x"ffea",
    000005 => x"4302",
    000006 => x"5801",
    000007 => x"40b2",
    000008 => x"4700",
    000009 => x"ffd0",
    000010 => x"4382",
    000011 => x"ff9e",
    000012 => x"4382",
    000013 => x"ffa6",
    000014 => x"4382",
    000015 => x"ffb4",
    000016 => x"4382",
    000017 => x"ffb2",
    000018 => x"4382",
    000019 => x"ffc4",
    000020 => x"4382",
    000021 => x"fff8",
    000022 => x"4382",
    000023 => x"fffa",
    000024 => x"4382",
    000025 => x"fffc",
    000026 => x"4382",
    000027 => x"fffe",
    000028 => x"9801",
    000029 => x"2404",
    000030 => x"4388",
    000031 => x"0000",
    000032 => x"5328",
    000033 => x"3ffa",
    000034 => x"4035",
    000035 => x"02de",
    000036 => x"4036",
    000037 => x"02de",
    000038 => x"4037",
    000039 => x"8000",
    000040 => x"9506",
    000041 => x"2404",
    000042 => x"45b7",
    000043 => x"0000",
    000044 => x"5327",
    000045 => x"3ffa",
    000046 => x"4304",
    000047 => x"4305",
    000048 => x"4306",
    000049 => x"4307",
    000050 => x"4308",
    000051 => x"4309",
    000052 => x"430a",
    000053 => x"430b",
    000054 => x"430c",
    000055 => x"430d",
    000056 => x"430e",
    000057 => x"430f",
    000058 => x"12b0",
    000059 => x"00b8",
    000060 => x"40b2",
    000061 => x"4700",
    000062 => x"ffd0",
    000063 => x"4302",
    000064 => x"4032",
    000065 => x"0010",
    000066 => x"4303",
    000067 => x"403e",
    000068 => x"ffa6",
    000069 => x"403f",
    000070 => x"ffa2",
    000071 => x"4c6d",
    000072 => x"930d",
    000073 => x"2001",
    000074 => x"4130",
    000075 => x"903d",
    000076 => x"000a",
    000077 => x"2006",
    000078 => x"b2be",
    000079 => x"0000",
    000080 => x"23fd",
    000081 => x"40b2",
    000082 => x"000d",
    000083 => x"ffa2",
    000084 => x"b2be",
    000085 => x"0000",
    000086 => x"23fd",
    000087 => x"4d8f",
    000088 => x"0000",
    000089 => x"531c",
    000090 => x"4030",
    000091 => x"008e",
    000092 => x"120a",
    000093 => x"421c",
    000094 => x"ffee",
    000095 => x"421a",
    000096 => x"ffec",
    000097 => x"434d",
    000098 => x"407e",
    000099 => x"0010",
    000100 => x"12b0",
    000101 => x"01e6",
    000102 => x"4c0e",
    000103 => x"da0e",
    000104 => x"4d0f",
    000105 => x"434c",
    000106 => x"4f0a",
    000107 => x"930f",
    000108 => x"2034",
    000109 => x"403d",
    000110 => x"95ff",
    000111 => x"9e0d",
    000112 => x"2830",
    000113 => x"407d",
    000114 => x"00ff",
    000115 => x"9c0d",
    000116 => x"2832",
    000117 => x"4a0d",
    000118 => x"5a0d",
    000119 => x"5d0d",
    000120 => x"5d0d",
    000121 => x"5d0d",
    000122 => x"5d0d",
    000123 => x"5d0d",
    000124 => x"5d0d",
    000125 => x"5d0d",
    000126 => x"dc0d",
    000127 => x"4d82",
    000128 => x"ffa4",
    000129 => x"40b2",
    000130 => x"fe81",
    000131 => x"ffa6",
    000132 => x"403a",
    000133 => x"0086",
    000134 => x"403c",
    000135 => x"02a0",
    000136 => x"128a",
    000137 => x"b2b2",
    000138 => x"ffe2",
    000139 => x"242a",
    000140 => x"4382",
    000141 => x"ffb2",
    000142 => x"434c",
    000143 => x"403f",
    000144 => x"ffb2",
    000145 => x"4c4d",
    000146 => x"4d8f",
    000147 => x"0000",
    000148 => x"407d",
    000149 => x"000b",
    000150 => x"531c",
    000151 => x"533d",
    000152 => x"930d",
    000153 => x"27f7",
    000154 => x"433e",
    000155 => x"4303",
    000156 => x"533e",
    000157 => x"930e",
    000158 => x"23fc",
    000159 => x"4030",
    000160 => x"012e",
    000161 => x"503e",
    000162 => x"6a00",
    000163 => x"633f",
    000164 => x"531c",
    000165 => x"4030",
    000166 => x"00d4",
    000167 => x"936a",
    000168 => x"2402",
    000169 => x"926a",
    000170 => x"2007",
    000171 => x"12b0",
    000172 => x"021c",
    000173 => x"535a",
    000174 => x"f03a",
    000175 => x"00ff",
    000176 => x"4030",
    000177 => x"00e2",
    000178 => x"12b0",
    000179 => x"0224",
    000180 => x"4030",
    000181 => x"015a",
    000182 => x"403c",
    000183 => x"02bc",
    000184 => x"128a",
    000185 => x"435c",
    000186 => x"413a",
    000187 => x"4130",
    000188 => x"5c0c",
    000189 => x"5c0c",
    000190 => x"5c0c",
    000191 => x"5c0c",
    000192 => x"5c0c",
    000193 => x"5c0c",
    000194 => x"5c0c",
    000195 => x"5c0c",
    000196 => x"5c0c",
    000197 => x"5c0c",
    000198 => x"5c0c",
    000199 => x"5c0c",
    000200 => x"5c0c",
    000201 => x"5c0c",
    000202 => x"5c0c",
    000203 => x"4130",
    000204 => x"533d",
    000205 => x"5c0c",
    000206 => x"930d",
    000207 => x"23fc",
    000208 => x"4130",
    000209 => x"5c0c",
    000210 => x"6d0d",
    000211 => x"5c0c",
    000212 => x"6d0d",
    000213 => x"5c0c",
    000214 => x"6d0d",
    000215 => x"5c0c",
    000216 => x"6d0d",
    000217 => x"5c0c",
    000218 => x"6d0d",
    000219 => x"5c0c",
    000220 => x"6d0d",
    000221 => x"5c0c",
    000222 => x"6d0d",
    000223 => x"5c0c",
    000224 => x"6d0d",
    000225 => x"5c0c",
    000226 => x"6d0d",
    000227 => x"5c0c",
    000228 => x"6d0d",
    000229 => x"5c0c",
    000230 => x"6d0d",
    000231 => x"5c0c",
    000232 => x"6d0d",
    000233 => x"5c0c",
    000234 => x"6d0d",
    000235 => x"5c0c",
    000236 => x"6d0d",
    000237 => x"5c0c",
    000238 => x"6d0d",
    000239 => x"4130",
    000240 => x"533e",
    000241 => x"5c0c",
    000242 => x"6d0d",
    000243 => x"930e",
    000244 => x"23fb",
    000245 => x"4130",
    000246 => x"c312",
    000247 => x"100c",
    000248 => x"c312",
    000249 => x"100c",
    000250 => x"c312",
    000251 => x"100c",
    000252 => x"c312",
    000253 => x"100c",
    000254 => x"c312",
    000255 => x"100c",
    000256 => x"c312",
    000257 => x"100c",
    000258 => x"c312",
    000259 => x"100c",
    000260 => x"c312",
    000261 => x"100c",
    000262 => x"c312",
    000263 => x"100c",
    000264 => x"c312",
    000265 => x"100c",
    000266 => x"c312",
    000267 => x"100c",
    000268 => x"c312",
    000269 => x"100c",
    000270 => x"c312",
    000271 => x"100c",
    000272 => x"c312",
    000273 => x"100c",
    000274 => x"c312",
    000275 => x"100c",
    000276 => x"4130",
    000277 => x"533d",
    000278 => x"c312",
    000279 => x"100c",
    000280 => x"930d",
    000281 => x"23fb",
    000282 => x"4130",
    000283 => x"c312",
    000284 => x"100d",
    000285 => x"100c",
    000286 => x"c312",
    000287 => x"100d",
    000288 => x"100c",
    000289 => x"c312",
    000290 => x"100d",
    000291 => x"100c",
    000292 => x"c312",
    000293 => x"100d",
    000294 => x"100c",
    000295 => x"c312",
    000296 => x"100d",
    000297 => x"100c",
    000298 => x"c312",
    000299 => x"100d",
    000300 => x"100c",
    000301 => x"c312",
    000302 => x"100d",
    000303 => x"100c",
    000304 => x"c312",
    000305 => x"100d",
    000306 => x"100c",
    000307 => x"c312",
    000308 => x"100d",
    000309 => x"100c",
    000310 => x"c312",
    000311 => x"100d",
    000312 => x"100c",
    000313 => x"c312",
    000314 => x"100d",
    000315 => x"100c",
    000316 => x"c312",
    000317 => x"100d",
    000318 => x"100c",
    000319 => x"c312",
    000320 => x"100d",
    000321 => x"100c",
    000322 => x"c312",
    000323 => x"100d",
    000324 => x"100c",
    000325 => x"c312",
    000326 => x"100d",
    000327 => x"100c",
    000328 => x"4130",
    000329 => x"533e",
    000330 => x"c312",
    000331 => x"100d",
    000332 => x"100c",
    000333 => x"930e",
    000334 => x"23fa",
    000335 => x"4130",
    000336 => x"420a",
    000337 => x"696c",
    000338 => x"6b6e",
    000339 => x"6e69",
    000340 => x"2067",
    000341 => x"454c",
    000342 => x"2044",
    000343 => x"6564",
    000344 => x"6f6d",
    000345 => x"7020",
    000346 => x"6f72",
    000347 => x"7267",
    000348 => x"6d61",
    000349 => x"000a",
    000350 => x"7245",
    000351 => x"6f72",
    000352 => x"2172",
    000353 => x"4e20",
    000354 => x"206f",
    000355 => x"5047",
    000356 => x"4f49",
    000357 => x"7520",
    000358 => x"696e",
    000359 => x"2074",
    000360 => x"7973",
    000361 => x"746e",
    000362 => x"6568",
    000363 => x"6973",
    000364 => x"657a",
    000365 => x"2164",
    000366 => x"0000",
    others => x"0000" -- nop
  );

end neo430_application_image;
