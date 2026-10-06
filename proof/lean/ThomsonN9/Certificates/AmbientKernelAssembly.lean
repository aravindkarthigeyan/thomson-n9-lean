import ThomsonN9.Certificates.AmbientKernelGeometry
import ThomsonN9.Certificates.AmbientCongruenceData
import ThomsonN9.Certificates.CircuitSums
import ThomsonN9.Certificates.CircuitRotation
set_option maxRecDepth 200000
set_option maxHeartbeats 0
namespace ThomsonN9.Certificates.AmbientKernel
open IntervalCircuit
open scoped BigOperators
def laplacianIndicesRow0 : Array ℕ := #[1507,1510,1513,39,41,43,78,81,84,191,11,194,337,340,343,560,563,566,836,11,839,1133,1136,1139,1508,1511,1514]
def laplacianIndicesRow1 : Array ℕ := #[1517,1521,1524,46,49,51,88,92,95,11,196,11,347,351,354,570,574,577,11,841,11,1143,1147,1150,1518,1522,1525]
def laplacianIndicesRow2 : Array ℕ := #[1528,1531,1535,54,56,59,99,102,106,200,11,204,358,361,365,581,584,588,845,11,849,1154,1157,1161,1529,1532,1536]
def laplacianIndicesRow3 : Array ℕ := #[39,41,43,1557,1561,1565,132,136,140,227,230,234,387,391,395,607,611,615,871,874,878,1185,1189,1193,1558,1562,1566]
def laplacianIndicesRow4 : Array ℕ := #[46,49,51,1570,1575,1579,145,150,154,238,243,246,400,405,409,620,625,629,882,887,890,1198,1203,1207,1571,1576,1580]
def laplacianIndicesRow5 : Array ℕ := #[54,56,59,1584,1588,1593,159,163,168,251,254,259,414,418,423,634,638,643,895,898,903,1212,1216,1221,1585,1589,1594]
def laplacianIndicesRow6 : Array ℕ := #[78,81,84,132,136,140,1616,1620,1624,282,286,290,446,450,454,666,670,674,924,928,932,1244,1248,1252,1617,1621,1625]
def laplacianIndicesRow7 : Array ℕ := #[88,92,95,145,150,154,1629,1634,1638,295,300,304,459,464,468,679,684,688,937,942,946,1257,1262,1266,1630,1635,1639]
def laplacianIndicesRow8 : Array ℕ := #[99,102,106,159,163,168,1643,1647,1652,309,313,318,473,477,482,693,697,702,951,955,960,1271,1275,1280,1644,1648,1653]
def laplacianIndicesRow9 : Array ℕ := #[191,11,194,227,230,234,282,286,290,1672,1676,1680,505,509,513,722,726,730,981,11,985,1300,1304,1308,1673,1677,1681]
def laplacianIndicesRow10 : Array ℕ := #[11,196,11,238,243,246,295,300,304,1685,1690,1694,518,523,527,735,740,744,11,988,11,1313,1318,1322,1686,1691,1695]
def laplacianIndicesRow11 : Array ℕ := #[200,11,204,251,254,259,309,313,318,1699,1703,1708,532,536,541,749,753,758,993,11,998,1327,1331,1336,1700,1704,1709]
def laplacianIndicesRow12 : Array ℕ := #[337,340,343,387,391,395,446,450,454,505,509,513,1728,1732,1736,778,782,786,1018,1022,1026,1356,1360,1364,1729,1733,1737]
def laplacianIndicesRow13 : Array ℕ := #[347,351,354,400,405,409,459,464,468,518,523,527,1741,1746,1750,791,796,800,1031,1036,1040,1369,1374,1378,1742,1747,1751]
def laplacianIndicesRow14 : Array ℕ := #[358,361,365,414,418,423,473,477,482,532,536,541,1755,1759,1764,805,809,814,1045,1049,1054,1383,1387,1392,1756,1760,1765]
def laplacianIndicesRow15 : Array ℕ := #[560,563,566,607,611,615,666,670,674,722,726,730,778,782,786,1784,1788,1792,1074,1078,1082,1412,1416,1420,1785,1789,1793]
def laplacianIndicesRow16 : Array ℕ := #[570,574,577,620,625,629,679,684,688,735,740,744,791,796,800,1797,1802,1806,1087,1092,1096,1425,1430,1434,1798,1803,1807]
def laplacianIndicesRow17 : Array ℕ := #[581,584,588,634,638,643,693,697,702,749,753,758,805,809,814,1811,1815,1820,1101,1105,1110,1439,1443,1448,1812,1816,1821]
def laplacianIndicesRow18 : Array ℕ := #[836,11,839,871,874,878,924,928,932,981,11,985,1018,1022,1026,1074,1078,1082,1840,1844,1080,1470,1474,11,1841,1845,11]
def laplacianIndicesRow19 : Array ℕ := #[11,841,11,882,887,890,937,942,946,11,988,11,1031,1036,1040,1087,1092,1096,1849,1854,1094,1479,1484,11,1850,1855,11]
def laplacianIndicesRow20 : Array ℕ := #[845,11,849,895,898,903,951,955,960,993,11,998,1045,1049,1054,1101,1105,1110,1099,1103,1857,11,11,1487,11,11,1858]
def laplacianIndicesRow21 : Array ℕ := #[1133,1136,1139,1185,1189,1193,1244,1248,1252,1300,1304,1308,1356,1360,1364,1412,1416,1420,1470,1474,11,1875,1472,1418,1876,11,11]
def laplacianIndicesRow22 : Array ℕ := #[1143,1147,1150,1198,1203,1207,1257,1262,1266,1313,1318,1322,1369,1374,1378,1425,1430,1434,1479,1484,11,1477,1881,1432,11,1882,11]
def laplacianIndicesRow23 : Array ℕ := #[1154,1157,1161,1212,1216,1221,1271,1275,1280,1327,1331,1336,1383,1387,1392,1439,1443,1448,11,11,1487,1437,1441,1884,11,11,1876]
def laplacianIndicesRow24 : Array ℕ := #[1508,1511,1514,1558,1562,1566,1617,1621,1625,1673,1677,1681,1729,1733,1737,1785,1789,1793,1841,1845,11,1876,11,11,1874,1843,1791]
def laplacianIndicesRow25 : Array ℕ := #[1518,1522,1525,1571,1576,1580,1630,1635,1639,1686,1691,1695,1742,1747,1751,1798,1803,1807,1850,1855,11,11,1882,11,1848,1880,1805]
def laplacianIndicesRow26 : Array ℕ := #[1529,1532,1536,1585,1589,1594,1644,1648,1653,1700,1704,1709,1756,1760,1765,1812,1816,1821,11,11,1858,11,11,1876,1810,1814,1883]
def laplacianIndices (i j : ℕ) : ℕ :=
  (#[laplacianIndicesRow0,laplacianIndicesRow1,laplacianIndicesRow2,laplacianIndicesRow3,laplacianIndicesRow4,laplacianIndicesRow5,laplacianIndicesRow6,laplacianIndicesRow7,laplacianIndicesRow8,laplacianIndicesRow9,laplacianIndicesRow10,laplacianIndicesRow11,laplacianIndicesRow12,laplacianIndicesRow13,laplacianIndicesRow14,laplacianIndicesRow15,laplacianIndicesRow16,laplacianIndicesRow17,laplacianIndicesRow18,laplacianIndicesRow19,laplacianIndicesRow20,laplacianIndicesRow21,laplacianIndicesRow22,laplacianIndicesRow23,laplacianIndicesRow24,laplacianIndicesRow25,laplacianIndicesRow26][i]?.getD #[])[j]?.getD 0
def constrainedIndicesRow0 : Array ℕ := #[1891,1510,1513,39,41,43,78,81,84,191,11,194,337,340,343,560,563,566,836,11,839,1133,1136,1139,1508,1511,1514]
def constrainedIndicesRow1 : Array ℕ := #[1517,1892,1524,46,49,51,88,92,95,11,196,11,347,351,354,570,574,577,11,841,11,1143,1147,1150,1518,1522,1525]
def constrainedIndicesRow2 : Array ℕ := #[1528,1531,1893,54,56,59,99,102,106,200,11,204,358,361,365,581,584,588,845,11,849,1154,1157,1161,1529,1532,1536]
def constrainedIndicesRow3 : Array ℕ := #[39,41,43,1895,1561,1565,132,136,140,227,230,234,387,391,395,607,611,615,871,874,878,1185,1189,1193,1558,1562,1566]
def constrainedIndicesRow4 : Array ℕ := #[46,49,51,1570,1896,1579,145,150,154,238,243,246,400,405,409,620,625,629,882,887,890,1198,1203,1207,1571,1576,1580]
def constrainedIndicesRow5 : Array ℕ := #[54,56,59,1584,1588,1897,159,163,168,251,254,259,414,418,423,634,638,643,895,898,903,1212,1216,1221,1585,1589,1594]
def constrainedIndicesRow6 : Array ℕ := #[78,81,84,132,136,140,1899,1620,1624,282,286,290,446,450,454,666,670,674,924,928,932,1244,1248,1252,1617,1621,1625]
def constrainedIndicesRow7 : Array ℕ := #[88,92,95,145,150,154,1629,1900,1638,295,300,304,459,464,468,679,684,688,937,942,946,1257,1262,1266,1630,1635,1639]
def constrainedIndicesRow8 : Array ℕ := #[99,102,106,159,163,168,1643,1647,1901,309,313,318,473,477,482,693,697,702,951,955,960,1271,1275,1280,1644,1648,1653]
def constrainedIndicesRow9 : Array ℕ := #[191,11,194,227,230,234,282,286,290,1903,1676,1680,505,509,513,722,726,730,981,11,985,1300,1304,1308,1673,1677,1681]
def constrainedIndicesRow10 : Array ℕ := #[11,196,11,238,243,246,295,300,304,1685,1904,1694,518,523,527,735,740,744,11,988,11,1313,1318,1322,1686,1691,1695]
def constrainedIndicesRow11 : Array ℕ := #[200,11,204,251,254,259,309,313,318,1699,1703,1905,532,536,541,749,753,758,993,11,998,1327,1331,1336,1700,1704,1709]
def constrainedIndicesRow12 : Array ℕ := #[337,340,343,387,391,395,446,450,454,505,509,513,1907,1732,1736,778,782,786,1018,1022,1026,1356,1360,1364,1729,1733,1737]
def constrainedIndicesRow13 : Array ℕ := #[347,351,354,400,405,409,459,464,468,518,523,527,1741,1908,1750,791,796,800,1031,1036,1040,1369,1374,1378,1742,1747,1751]
def constrainedIndicesRow14 : Array ℕ := #[358,361,365,414,418,423,473,477,482,532,536,541,1755,1759,1909,805,809,814,1045,1049,1054,1383,1387,1392,1756,1760,1765]
def constrainedIndicesRow15 : Array ℕ := #[560,563,566,607,611,615,666,670,674,722,726,730,778,782,786,1911,1788,1792,1074,1078,1082,1412,1416,1420,1785,1789,1793]
def constrainedIndicesRow16 : Array ℕ := #[570,574,577,620,625,629,679,684,688,735,740,744,791,796,800,1797,1912,1806,1087,1092,1096,1425,1430,1434,1798,1803,1807]
def constrainedIndicesRow17 : Array ℕ := #[581,584,588,634,638,643,693,697,702,749,753,758,805,809,814,1811,1815,1913,1101,1105,1110,1439,1443,1448,1812,1816,1821]
def constrainedIndicesRow18 : Array ℕ := #[836,11,839,871,874,878,924,928,932,981,11,985,1018,1022,1026,1074,1078,1082,1915,1844,1080,1470,1474,11,1841,1845,11]
def constrainedIndicesRow19 : Array ℕ := #[11,841,11,882,887,890,937,942,946,11,988,11,1031,1036,1040,1087,1092,1096,1849,1916,1094,1479,1484,11,1850,1855,11]
def constrainedIndicesRow20 : Array ℕ := #[845,11,849,895,898,903,951,955,960,993,11,998,1045,1049,1054,1101,1105,1110,1099,1103,1917,11,11,1487,11,11,1858]
def constrainedIndicesRow21 : Array ℕ := #[1133,1136,1139,1185,1189,1193,1244,1248,1252,1300,1304,1308,1356,1360,1364,1412,1416,1420,1470,1474,11,1919,1472,1418,1876,11,11]
def constrainedIndicesRow22 : Array ℕ := #[1143,1147,1150,1198,1203,1207,1257,1262,1266,1313,1318,1322,1369,1374,1378,1425,1430,1434,1479,1484,11,1477,1920,1432,11,1882,11]
def constrainedIndicesRow23 : Array ℕ := #[1154,1157,1161,1212,1216,1221,1271,1275,1280,1327,1331,1336,1383,1387,1392,1439,1443,1448,11,11,1487,1437,1441,1921,11,11,1876]
def constrainedIndicesRow24 : Array ℕ := #[1508,1511,1514,1558,1562,1566,1617,1621,1625,1673,1677,1681,1729,1733,1737,1785,1789,1793,1841,1845,11,1876,11,11,1923,1843,1791]
def constrainedIndicesRow25 : Array ℕ := #[1518,1522,1525,1571,1576,1580,1630,1635,1639,1686,1691,1695,1742,1747,1751,1798,1803,1807,1850,1855,11,11,1882,11,1848,1924,1805]
def constrainedIndicesRow26 : Array ℕ := #[1529,1532,1536,1585,1589,1594,1644,1648,1653,1700,1704,1709,1756,1760,1765,1812,1816,1821,11,11,1858,11,11,1876,1810,1814,1925]
def constrainedIndices (i j : ℕ) : ℕ :=
  (#[constrainedIndicesRow0,constrainedIndicesRow1,constrainedIndicesRow2,constrainedIndicesRow3,constrainedIndicesRow4,constrainedIndicesRow5,constrainedIndicesRow6,constrainedIndicesRow7,constrainedIndicesRow8,constrainedIndicesRow9,constrainedIndicesRow10,constrainedIndicesRow11,constrainedIndicesRow12,constrainedIndicesRow13,constrainedIndicesRow14,constrainedIndicesRow15,constrainedIndicesRow16,constrainedIndicesRow17,constrainedIndicesRow18,constrainedIndicesRow19,constrainedIndicesRow20,constrainedIndicesRow21,constrainedIndicesRow22,constrainedIndicesRow23,constrainedIndicesRow24,constrainedIndicesRow25,constrainedIndicesRow26][i]?.getD #[])[j]?.getD 0
def augmentedIndicesRow0 : Array ℕ := #[1928,1510,1930,1931,41,1933,1934,81,1935,1937,11,1938,1939,340,1940,1941,563,1942,836,11,1943,1133,1136,1945,1508,1511,1946]
def augmentedIndicesRow1 : Array ℕ := #[1517,1948,1524,1950,1953,1955,1957,1958,1960,11,1963,11,1964,1966,1967,1968,1969,1970,11,1972,11,1974,1976,1978,1980,1981,1983]
def augmentedIndicesRow2 : Array ℕ := #[1985,1531,1987,1988,56,1990,1991,102,1992,1994,11,1995,1996,361,1997,1998,584,1999,845,11,2000,1154,1157,2002,1529,1532,2003]
def augmentedIndicesRow3 : Array ℕ := #[1931,2005,2006,2008,2010,2011,2014,2015,2016,2017,2018,2019,2021,2022,2023,2025,2026,2027,871,2029,2030,2032,2034,2035,2037,2038,2039]
def augmentedIndicesRow4 : Array ℕ := #[46,2042,51,2044,2047,2048,2050,2051,2052,238,2054,246,2055,2057,2058,2059,2060,2061,882,2063,890,2065,2067,2068,2070,2071,2072]
def augmentedIndicesRow5 : Array ℕ := #[2074,2076,2078,2079,2080,2083,2084,2085,2088,2090,2092,2093,2094,2095,2096,2097,2098,2099,895,898,2100,1212,1216,2104,1585,1589,2107]
def augmentedIndicesRow6 : Array ℕ := #[1934,2109,2110,2113,2115,2016,2117,2118,2119,2120,2121,2122,2124,2125,2126,2128,2129,2130,924,2132,2133,2135,2137,2138,2140,2141,2142]
def augmentedIndicesRow7 : Array ℕ := #[88,2143,95,2144,2051,2145,2146,2147,2148,295,2149,304,2150,2151,2152,2153,2154,2155,937,2156,946,2157,2158,2159,2160,2161,2162]
def augmentedIndicesRow8 : Array ℕ := #[2163,2165,2166,2084,2167,2170,2171,2172,2174,2175,2177,2178,2179,2180,2181,2182,2183,2184,951,955,2185,1271,1275,2188,1644,1648,2191]
def augmentedIndicesRow9 : Array ℕ := #[2193,11,2195,2196,230,2198,2199,286,2200,2201,1676,2202,2203,509,2204,2205,726,2206,981,11,2207,1300,1304,2209,1673,1677,2210]
def augmentedIndicesRow10 : Array ℕ := #[11,2213,11,2214,2216,2218,2219,2220,2222,1685,2224,1694,2225,2227,2228,2229,2230,2231,11,2232,11,2233,2234,2236,2237,2238,2240]
def augmentedIndicesRow11 : Array ℕ := #[2241,11,1995,2242,254,2243,2244,313,2245,2246,1703,2247,2248,536,2249,2250,753,2251,993,11,2252,1327,1331,2253,1700,1704,2254]
def augmentedIndicesRow12 : Array ℕ := #[2255,2256,2257,2259,2022,2260,2262,2263,2264,2203,2265,2266,2268,2269,2270,2272,2273,2274,1018,2275,2276,2277,2278,2279,2280,2281,2282]
def augmentedIndicesRow13 : Array ℕ := #[347,2284,354,2055,2286,2287,2288,2289,2290,518,2292,527,2293,2295,2296,2297,2298,2299,1031,2300,1040,2301,2302,2303,2304,2305,2306]
def augmentedIndicesRow14 : Array ℕ := #[2307,2308,2309,2310,2311,2096,2312,2313,2314,2315,2316,2317,2318,2319,2320,2321,2322,2323,1045,1049,2324,1383,1387,2325,1756,1760,2326]
def augmentedIndicesRow15 : Array ℕ := #[2327,2328,2329,2331,2332,2333,2335,2129,2336,2205,2337,2338,2340,2341,2274,2343,2344,2345,1074,2346,2347,2348,2349,2350,2351,2352,2353]
def augmentedIndicesRow16 : Array ℕ := #[570,2354,577,2355,2356,2357,2153,2358,2359,735,2360,744,2361,2298,2362,2363,2364,2365,1087,2366,1096,2367,2368,2369,2370,2371,2372]
def augmentedIndicesRow17 : Array ℕ := #[2373,2374,2375,2376,2377,2378,2379,2380,2184,2381,2382,2383,2321,2384,2385,2386,2387,2388,1101,1105,2389,1439,1443,2390,1812,1816,2391]
def augmentedIndicesRow18 : Array ℕ := #[836,11,839,871,874,878,924,928,932,981,11,985,1018,1022,1026,1074,1078,1082,1915,1844,1080,1470,1474,11,1841,1845,11]
def augmentedIndicesRow19 : Array ℕ := #[11,2393,11,2395,2397,890,2399,2400,946,11,2401,11,2402,2403,1040,2404,2405,1096,1849,2406,1094,2408,2409,11,2411,2412,11]
def augmentedIndicesRow20 : Array ℕ := #[2413,11,2000,2414,898,2100,2415,955,2185,2416,11,2252,2417,1049,2324,2418,1105,2389,1099,1103,2419,11,11,2420,11,11,2421]
def augmentedIndicesRow21 : Array ℕ := #[1133,2423,1139,2425,2427,1193,2429,2430,1252,1300,2431,1308,2432,2433,1364,2434,2435,1420,1470,2437,11,2438,2440,1418,2442,2439,11]
def augmentedIndicesRow22 : Array ℕ := #[1143,2444,1150,2446,2448,1207,2450,2451,1266,1313,2452,1322,2453,2454,1378,2455,2456,1434,1479,2409,11,2458,2460,1432,2461,2462,11]
def augmentedIndicesRow23 : Array ℕ := #[2464,2466,2468,2469,2470,2474,2475,2476,2479,2481,2483,2484,2485,2486,2487,2488,2489,2490,11,11,2420,1437,1441,2492,11,11,2495]
def augmentedIndicesRow24 : Array ℕ := #[1508,2497,1514,2499,2501,1566,2503,2504,1625,1673,2505,1681,2506,2507,1737,2508,2509,1793,1841,2511,11,2513,2514,11,2516,2517,1791]
def augmentedIndicesRow25 : Array ℕ := #[1518,2518,1525,2519,2520,1580,2521,2522,1639,1686,2523,1695,2524,2525,1751,2526,2527,1807,1850,2412,11,2457,2462,11,2528,2529,1805]
def augmentedIndicesRow26 : Array ℕ := #[2530,2532,2533,2534,2535,2538,2539,2540,2543,2544,2546,2547,2548,2549,2550,2551,2552,2553,11,11,2421,11,11,2556,1810,1814,2558]
def augmentedIndices (i j : ℕ) : ℕ :=
  (#[augmentedIndicesRow0,augmentedIndicesRow1,augmentedIndicesRow2,augmentedIndicesRow3,augmentedIndicesRow4,augmentedIndicesRow5,augmentedIndicesRow6,augmentedIndicesRow7,augmentedIndicesRow8,augmentedIndicesRow9,augmentedIndicesRow10,augmentedIndicesRow11,augmentedIndicesRow12,augmentedIndicesRow13,augmentedIndicesRow14,augmentedIndicesRow15,augmentedIndicesRow16,augmentedIndicesRow17,augmentedIndicesRow18,augmentedIndicesRow19,augmentedIndicesRow20,augmentedIndicesRow21,augmentedIndicesRow22,augmentedIndicesRow23,augmentedIndicesRow24,augmentedIndicesRow25,augmentedIndicesRow26][i]?.getD #[])[j]?.getD 0
def flatIndex (i : Fin 9 × Fin 3) : ℕ := 3*i.1.val+i.2.val
def negativeShift : ℕ := 2560
def lagrangeCorrections : Fin 9 → ℕ := ![1890,1894,1898,1902,1906,1910,1914,1918,1922]
def lambdaIndices : Fin 9 → ℕ := ![1540,1599,1658,1714,1770,1826,1863,1889,1888]
def diagonalSum_0_0_0 : SumRecipe where
  term := fun i => #[11,38,76,189,335,558,834,1131,1506][i]?.getD 0
  accumulator := fun i => #[11,11,38,77,190,336,559,835,1132,1507][i]?.getD 0
theorem diagonalSum_0_0_0_checked : diagonalSum_0_0_0.Check nodes 9 := by decide
def diagonalSum_0_0_1 : SumRecipe where
  term := fun i => #[11,40,79,11,338,561,11,1134,1509][i]?.getD 0
  accumulator := fun i => #[11,11,40,80,80,339,562,562,1135,1510][i]?.getD 0
theorem diagonalSum_0_0_1_checked : diagonalSum_0_0_1.Check nodes 9 := by decide
def diagonalSum_0_0_2 : SumRecipe where
  term := fun i => #[11,42,82,192,341,564,837,1137,1512][i]?.getD 0
  accumulator := fun i => #[11,11,42,83,193,342,565,838,1138,1513][i]?.getD 0
theorem diagonalSum_0_0_2_checked : diagonalSum_0_0_2.Check nodes 9 := by decide
def diagonalSum_0_1_0 : SumRecipe where
  term := fun i => #[11,45,86,11,345,568,11,1141,1516][i]?.getD 0
  accumulator := fun i => #[11,11,45,87,87,346,569,569,1142,1517][i]?.getD 0
theorem diagonalSum_0_1_0_checked : diagonalSum_0_1_0.Check nodes 9 := by decide
def diagonalSum_0_1_1 : SumRecipe where
  term := fun i => #[11,48,90,188,349,572,833,1145,1520][i]?.getD 0
  accumulator := fun i => #[11,11,48,91,195,350,573,840,1146,1521][i]?.getD 0
theorem diagonalSum_0_1_1_checked : diagonalSum_0_1_1.Check nodes 9 := by decide
def diagonalSum_0_1_2 : SumRecipe where
  term := fun i => #[11,50,93,11,352,575,11,1148,1523][i]?.getD 0
  accumulator := fun i => #[11,11,50,94,94,353,576,576,1149,1524][i]?.getD 0
theorem diagonalSum_0_1_2_checked : diagonalSum_0_1_2.Check nodes 9 := by decide
def diagonalSum_0_2_0 : SumRecipe where
  term := fun i => #[11,53,97,198,356,579,843,1152,1527][i]?.getD 0
  accumulator := fun i => #[11,11,53,98,199,357,580,844,1153,1528][i]?.getD 0
theorem diagonalSum_0_2_0_checked : diagonalSum_0_2_0.Check nodes 9 := by decide
def diagonalSum_0_2_1 : SumRecipe where
  term := fun i => #[11,55,100,11,359,582,11,1155,1530][i]?.getD 0
  accumulator := fun i => #[11,11,55,101,101,360,583,583,1156,1531][i]?.getD 0
theorem diagonalSum_0_2_1_checked : diagonalSum_0_2_1.Check nodes 9 := by decide
def diagonalSum_0_2_2 : SumRecipe where
  term := fun i => #[11,58,104,202,363,586,847,1159,1534][i]?.getD 0
  accumulator := fun i => #[11,11,58,105,203,364,587,848,1160,1535][i]?.getD 0
theorem diagonalSum_0_2_2_checked : diagonalSum_0_2_2.Check nodes 9 := by decide
def diagonalSum_1_0_0 : SumRecipe where
  term := fun i => #[38,11,129,224,384,604,868,1182,1555][i]?.getD 0
  accumulator := fun i => #[11,38,38,131,226,386,606,870,1184,1557][i]?.getD 0
theorem diagonalSum_1_0_0_checked : diagonalSum_1_0_0.Check nodes 9 := by decide
def diagonalSum_1_0_1 : SumRecipe where
  term := fun i => #[40,11,133,228,388,608,872,1186,1559][i]?.getD 0
  accumulator := fun i => #[11,40,40,135,229,390,610,873,1188,1561][i]?.getD 0
theorem diagonalSum_1_0_1_checked : diagonalSum_1_0_1.Check nodes 9 := by decide
def diagonalSum_1_0_2 : SumRecipe where
  term := fun i => #[42,11,137,231,392,612,875,1190,1563][i]?.getD 0
  accumulator := fun i => #[11,42,42,139,233,394,614,877,1192,1565][i]?.getD 0
theorem diagonalSum_1_0_2_checked : diagonalSum_1_0_2.Check nodes 9 := by decide
def diagonalSum_1_1_0 : SumRecipe where
  term := fun i => #[45,11,142,236,397,617,880,1195,1568][i]?.getD 0
  accumulator := fun i => #[11,45,45,144,237,399,619,881,1197,1570][i]?.getD 0
theorem diagonalSum_1_1_0_checked : diagonalSum_1_1_0.Check nodes 9 := by decide
def diagonalSum_1_1_1 : SumRecipe where
  term := fun i => #[48,11,147,240,402,622,884,1200,1573][i]?.getD 0
  accumulator := fun i => #[11,48,48,149,242,404,624,886,1202,1575][i]?.getD 0
theorem diagonalSum_1_1_1_checked : diagonalSum_1_1_1.Check nodes 9 := by decide
def diagonalSum_1_1_2 : SumRecipe where
  term := fun i => #[50,11,151,244,406,626,888,1204,1577][i]?.getD 0
  accumulator := fun i => #[11,50,50,153,245,408,628,889,1206,1579][i]?.getD 0
theorem diagonalSum_1_1_2_checked : diagonalSum_1_1_2.Check nodes 9 := by decide
def diagonalSum_1_2_0 : SumRecipe where
  term := fun i => #[53,11,156,248,411,631,892,1209,1582][i]?.getD 0
  accumulator := fun i => #[11,53,53,158,250,413,633,894,1211,1584][i]?.getD 0
theorem diagonalSum_1_2_0_checked : diagonalSum_1_2_0.Check nodes 9 := by decide
def diagonalSum_1_2_1 : SumRecipe where
  term := fun i => #[55,11,160,252,415,635,896,1213,1586][i]?.getD 0
  accumulator := fun i => #[11,55,55,162,253,417,637,897,1215,1588][i]?.getD 0
theorem diagonalSum_1_2_1_checked : diagonalSum_1_2_1.Check nodes 9 := by decide
def diagonalSum_1_2_2 : SumRecipe where
  term := fun i => #[58,11,165,256,420,640,900,1218,1591][i]?.getD 0
  accumulator := fun i => #[11,58,58,167,258,422,642,902,1220,1593][i]?.getD 0
theorem diagonalSum_1_2_2_checked : diagonalSum_1_2_2.Check nodes 9 := by decide
def diagonalSum_2_0_0 : SumRecipe where
  term := fun i => #[76,129,11,279,443,663,921,1241,1614][i]?.getD 0
  accumulator := fun i => #[11,76,130,130,281,445,665,923,1243,1616][i]?.getD 0
theorem diagonalSum_2_0_0_checked : diagonalSum_2_0_0.Check nodes 9 := by decide
def diagonalSum_2_0_1 : SumRecipe where
  term := fun i => #[79,133,11,283,447,667,925,1245,1618][i]?.getD 0
  accumulator := fun i => #[11,79,134,134,285,449,669,927,1247,1620][i]?.getD 0
theorem diagonalSum_2_0_1_checked : diagonalSum_2_0_1.Check nodes 9 := by decide
def diagonalSum_2_0_2 : SumRecipe where
  term := fun i => #[82,137,11,287,451,671,929,1249,1622][i]?.getD 0
  accumulator := fun i => #[11,82,138,138,289,453,673,931,1251,1624][i]?.getD 0
theorem diagonalSum_2_0_2_checked : diagonalSum_2_0_2.Check nodes 9 := by decide
def diagonalSum_2_1_0 : SumRecipe where
  term := fun i => #[86,142,11,292,456,676,934,1254,1627][i]?.getD 0
  accumulator := fun i => #[11,86,143,143,294,458,678,936,1256,1629][i]?.getD 0
theorem diagonalSum_2_1_0_checked : diagonalSum_2_1_0.Check nodes 9 := by decide
def diagonalSum_2_1_1 : SumRecipe where
  term := fun i => #[90,147,11,297,461,681,939,1259,1632][i]?.getD 0
  accumulator := fun i => #[11,90,148,148,299,463,683,941,1261,1634][i]?.getD 0
theorem diagonalSum_2_1_1_checked : diagonalSum_2_1_1.Check nodes 9 := by decide
def diagonalSum_2_1_2 : SumRecipe where
  term := fun i => #[93,151,11,301,465,685,943,1263,1636][i]?.getD 0
  accumulator := fun i => #[11,93,152,152,303,467,687,945,1265,1638][i]?.getD 0
theorem diagonalSum_2_1_2_checked : diagonalSum_2_1_2.Check nodes 9 := by decide
def diagonalSum_2_2_0 : SumRecipe where
  term := fun i => #[97,156,11,306,470,690,948,1268,1641][i]?.getD 0
  accumulator := fun i => #[11,97,157,157,308,472,692,950,1270,1643][i]?.getD 0
theorem diagonalSum_2_2_0_checked : diagonalSum_2_2_0.Check nodes 9 := by decide
def diagonalSum_2_2_1 : SumRecipe where
  term := fun i => #[100,160,11,310,474,694,952,1272,1645][i]?.getD 0
  accumulator := fun i => #[11,100,161,161,312,476,696,954,1274,1647][i]?.getD 0
theorem diagonalSum_2_2_1_checked : diagonalSum_2_2_1.Check nodes 9 := by decide
def diagonalSum_2_2_2 : SumRecipe where
  term := fun i => #[104,165,11,315,479,699,957,1277,1650][i]?.getD 0
  accumulator := fun i => #[11,104,166,166,317,481,701,959,1279,1652][i]?.getD 0
theorem diagonalSum_2_2_2_checked : diagonalSum_2_2_2.Check nodes 9 := by decide
def diagonalSum_3_0_0 : SumRecipe where
  term := fun i => #[189,224,279,11,502,719,978,1297,1670][i]?.getD 0
  accumulator := fun i => #[11,189,225,280,280,504,721,980,1299,1672][i]?.getD 0
theorem diagonalSum_3_0_0_checked : diagonalSum_3_0_0.Check nodes 9 := by decide
def diagonalSum_3_0_1 : SumRecipe where
  term := fun i => #[11,228,283,11,506,723,11,1301,1674][i]?.getD 0
  accumulator := fun i => #[11,11,228,284,284,508,725,725,1303,1676][i]?.getD 0
theorem diagonalSum_3_0_1_checked : diagonalSum_3_0_1.Check nodes 9 := by decide
def diagonalSum_3_0_2 : SumRecipe where
  term := fun i => #[192,231,287,11,510,727,982,1305,1678][i]?.getD 0
  accumulator := fun i => #[11,192,232,288,288,512,729,984,1307,1680][i]?.getD 0
theorem diagonalSum_3_0_2_checked : diagonalSum_3_0_2.Check nodes 9 := by decide
def diagonalSum_3_1_0 : SumRecipe where
  term := fun i => #[11,236,292,11,515,732,11,1310,1683][i]?.getD 0
  accumulator := fun i => #[11,11,236,293,293,517,734,734,1312,1685][i]?.getD 0
theorem diagonalSum_3_1_0_checked : diagonalSum_3_1_0.Check nodes 9 := by decide
def diagonalSum_3_1_1 : SumRecipe where
  term := fun i => #[188,240,297,11,520,737,977,1315,1688][i]?.getD 0
  accumulator := fun i => #[11,188,241,298,298,522,739,987,1317,1690][i]?.getD 0
theorem diagonalSum_3_1_1_checked : diagonalSum_3_1_1.Check nodes 9 := by decide
def diagonalSum_3_1_2 : SumRecipe where
  term := fun i => #[11,244,301,11,524,741,11,1319,1692][i]?.getD 0
  accumulator := fun i => #[11,11,244,302,302,526,743,743,1321,1694][i]?.getD 0
theorem diagonalSum_3_1_2_checked : diagonalSum_3_1_2.Check nodes 9 := by decide
def diagonalSum_3_2_0 : SumRecipe where
  term := fun i => #[198,248,306,11,529,746,990,1324,1697][i]?.getD 0
  accumulator := fun i => #[11,198,249,307,307,531,748,992,1326,1699][i]?.getD 0
theorem diagonalSum_3_2_0_checked : diagonalSum_3_2_0.Check nodes 9 := by decide
def diagonalSum_3_2_1 : SumRecipe where
  term := fun i => #[11,252,310,11,533,750,11,1328,1701][i]?.getD 0
  accumulator := fun i => #[11,11,252,311,311,535,752,752,1330,1703][i]?.getD 0
theorem diagonalSum_3_2_1_checked : diagonalSum_3_2_1.Check nodes 9 := by decide
def diagonalSum_3_2_2 : SumRecipe where
  term := fun i => #[202,256,315,11,538,755,995,1333,1706][i]?.getD 0
  accumulator := fun i => #[11,202,257,316,316,540,757,997,1335,1708][i]?.getD 0
theorem diagonalSum_3_2_2_checked : diagonalSum_3_2_2.Check nodes 9 := by decide
def diagonalSum_4_0_0 : SumRecipe where
  term := fun i => #[335,384,443,502,11,775,1015,1353,1726][i]?.getD 0
  accumulator := fun i => #[11,335,385,444,503,503,777,1017,1355,1728][i]?.getD 0
theorem diagonalSum_4_0_0_checked : diagonalSum_4_0_0.Check nodes 9 := by decide
def diagonalSum_4_0_1 : SumRecipe where
  term := fun i => #[338,388,447,506,11,779,1019,1357,1730][i]?.getD 0
  accumulator := fun i => #[11,338,389,448,507,507,781,1021,1359,1732][i]?.getD 0
theorem diagonalSum_4_0_1_checked : diagonalSum_4_0_1.Check nodes 9 := by decide
def diagonalSum_4_0_2 : SumRecipe where
  term := fun i => #[341,392,451,510,11,783,1023,1361,1734][i]?.getD 0
  accumulator := fun i => #[11,341,393,452,511,511,785,1025,1363,1736][i]?.getD 0
theorem diagonalSum_4_0_2_checked : diagonalSum_4_0_2.Check nodes 9 := by decide
def diagonalSum_4_1_0 : SumRecipe where
  term := fun i => #[345,397,456,515,11,788,1028,1366,1739][i]?.getD 0
  accumulator := fun i => #[11,345,398,457,516,516,790,1030,1368,1741][i]?.getD 0
theorem diagonalSum_4_1_0_checked : diagonalSum_4_1_0.Check nodes 9 := by decide
def diagonalSum_4_1_1 : SumRecipe where
  term := fun i => #[349,402,461,520,11,793,1033,1371,1744][i]?.getD 0
  accumulator := fun i => #[11,349,403,462,521,521,795,1035,1373,1746][i]?.getD 0
theorem diagonalSum_4_1_1_checked : diagonalSum_4_1_1.Check nodes 9 := by decide
def diagonalSum_4_1_2 : SumRecipe where
  term := fun i => #[352,406,465,524,11,797,1037,1375,1748][i]?.getD 0
  accumulator := fun i => #[11,352,407,466,525,525,799,1039,1377,1750][i]?.getD 0
theorem diagonalSum_4_1_2_checked : diagonalSum_4_1_2.Check nodes 9 := by decide
def diagonalSum_4_2_0 : SumRecipe where
  term := fun i => #[356,411,470,529,11,802,1042,1380,1753][i]?.getD 0
  accumulator := fun i => #[11,356,412,471,530,530,804,1044,1382,1755][i]?.getD 0
theorem diagonalSum_4_2_0_checked : diagonalSum_4_2_0.Check nodes 9 := by decide
def diagonalSum_4_2_1 : SumRecipe where
  term := fun i => #[359,415,474,533,11,806,1046,1384,1757][i]?.getD 0
  accumulator := fun i => #[11,359,416,475,534,534,808,1048,1386,1759][i]?.getD 0
theorem diagonalSum_4_2_1_checked : diagonalSum_4_2_1.Check nodes 9 := by decide
def diagonalSum_4_2_2 : SumRecipe where
  term := fun i => #[363,420,479,538,11,811,1051,1389,1762][i]?.getD 0
  accumulator := fun i => #[11,363,421,480,539,539,813,1053,1391,1764][i]?.getD 0
theorem diagonalSum_4_2_2_checked : diagonalSum_4_2_2.Check nodes 9 := by decide
def diagonalSum_5_0_0 : SumRecipe where
  term := fun i => #[558,604,663,719,775,11,1071,1409,1782][i]?.getD 0
  accumulator := fun i => #[11,558,605,664,720,776,776,1073,1411,1784][i]?.getD 0
theorem diagonalSum_5_0_0_checked : diagonalSum_5_0_0.Check nodes 9 := by decide
def diagonalSum_5_0_1 : SumRecipe where
  term := fun i => #[561,608,667,723,779,11,1075,1413,1786][i]?.getD 0
  accumulator := fun i => #[11,561,609,668,724,780,780,1077,1415,1788][i]?.getD 0
theorem diagonalSum_5_0_1_checked : diagonalSum_5_0_1.Check nodes 9 := by decide
def diagonalSum_5_0_2 : SumRecipe where
  term := fun i => #[564,612,671,727,783,11,1079,1417,1790][i]?.getD 0
  accumulator := fun i => #[11,564,613,672,728,784,784,1081,1419,1792][i]?.getD 0
theorem diagonalSum_5_0_2_checked : diagonalSum_5_0_2.Check nodes 9 := by decide
def diagonalSum_5_1_0 : SumRecipe where
  term := fun i => #[568,617,676,732,788,11,1084,1422,1795][i]?.getD 0
  accumulator := fun i => #[11,568,618,677,733,789,789,1086,1424,1797][i]?.getD 0
theorem diagonalSum_5_1_0_checked : diagonalSum_5_1_0.Check nodes 9 := by decide
def diagonalSum_5_1_1 : SumRecipe where
  term := fun i => #[572,622,681,737,793,11,1089,1427,1800][i]?.getD 0
  accumulator := fun i => #[11,572,623,682,738,794,794,1091,1429,1802][i]?.getD 0
theorem diagonalSum_5_1_1_checked : diagonalSum_5_1_1.Check nodes 9 := by decide
def diagonalSum_5_1_2 : SumRecipe where
  term := fun i => #[575,626,685,741,797,11,1093,1431,1804][i]?.getD 0
  accumulator := fun i => #[11,575,627,686,742,798,798,1095,1433,1806][i]?.getD 0
theorem diagonalSum_5_1_2_checked : diagonalSum_5_1_2.Check nodes 9 := by decide
def diagonalSum_5_2_0 : SumRecipe where
  term := fun i => #[579,631,690,746,802,11,1098,1436,1809][i]?.getD 0
  accumulator := fun i => #[11,579,632,691,747,803,803,1100,1438,1811][i]?.getD 0
theorem diagonalSum_5_2_0_checked : diagonalSum_5_2_0.Check nodes 9 := by decide
def diagonalSum_5_2_1 : SumRecipe where
  term := fun i => #[582,635,694,750,806,11,1102,1440,1813][i]?.getD 0
  accumulator := fun i => #[11,582,636,695,751,807,807,1104,1442,1815][i]?.getD 0
theorem diagonalSum_5_2_1_checked : diagonalSum_5_2_1.Check nodes 9 := by decide
def diagonalSum_5_2_2 : SumRecipe where
  term := fun i => #[586,640,699,755,811,11,1107,1445,1818][i]?.getD 0
  accumulator := fun i => #[11,586,641,700,756,812,812,1109,1447,1820][i]?.getD 0
theorem diagonalSum_5_2_2_checked : diagonalSum_5_2_2.Check nodes 9 := by decide
def diagonalSum_6_0_0 : SumRecipe where
  term := fun i => #[834,868,921,978,1015,1071,11,1467,1838][i]?.getD 0
  accumulator := fun i => #[11,834,869,922,979,1016,1072,1072,1469,1840][i]?.getD 0
theorem diagonalSum_6_0_0_checked : diagonalSum_6_0_0.Check nodes 9 := by decide
def diagonalSum_6_0_1 : SumRecipe where
  term := fun i => #[11,872,925,11,1019,1075,11,1471,1842][i]?.getD 0
  accumulator := fun i => #[11,11,872,926,926,1020,1076,1076,1473,1844][i]?.getD 0
theorem diagonalSum_6_0_1_checked : diagonalSum_6_0_1.Check nodes 9 := by decide
def diagonalSum_6_0_2 : SumRecipe where
  term := fun i => #[837,875,929,982,1023,1079,11,11,11][i]?.getD 0
  accumulator := fun i => #[11,837,876,930,983,1024,1080,1080,1080,1080][i]?.getD 0
theorem diagonalSum_6_0_2_checked : diagonalSum_6_0_2.Check nodes 9 := by decide
def diagonalSum_6_1_0 : SumRecipe where
  term := fun i => #[11,880,934,11,1028,1084,11,1476,1847][i]?.getD 0
  accumulator := fun i => #[11,11,880,935,935,1029,1085,1085,1478,1849][i]?.getD 0
theorem diagonalSum_6_1_0_checked : diagonalSum_6_1_0.Check nodes 9 := by decide
def diagonalSum_6_1_1 : SumRecipe where
  term := fun i => #[833,884,939,977,1033,1089,11,1481,1852][i]?.getD 0
  accumulator := fun i => #[11,833,885,940,986,1034,1090,1090,1483,1854][i]?.getD 0
theorem diagonalSum_6_1_1_checked : diagonalSum_6_1_1.Check nodes 9 := by decide
def diagonalSum_6_1_2 : SumRecipe where
  term := fun i => #[11,888,943,11,1037,1093,11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,888,944,944,1038,1094,1094,1094,1094][i]?.getD 0
theorem diagonalSum_6_1_2_checked : diagonalSum_6_1_2.Check nodes 9 := by decide
def diagonalSum_6_2_0 : SumRecipe where
  term := fun i => #[843,892,948,990,1042,1098,11,11,11][i]?.getD 0
  accumulator := fun i => #[11,843,893,949,991,1043,1099,1099,1099,1099][i]?.getD 0
theorem diagonalSum_6_2_0_checked : diagonalSum_6_2_0.Check nodes 9 := by decide
def diagonalSum_6_2_1 : SumRecipe where
  term := fun i => #[11,896,952,11,1046,1102,11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,896,953,953,1047,1103,1103,1103,1103][i]?.getD 0
theorem diagonalSum_6_2_1_checked : diagonalSum_6_2_1.Check nodes 9 := by decide
def diagonalSum_6_2_2 : SumRecipe where
  term := fun i => #[847,900,957,995,1051,1107,11,1466,1837][i]?.getD 0
  accumulator := fun i => #[11,847,901,958,996,1052,1108,1108,1486,1857][i]?.getD 0
theorem diagonalSum_6_2_2_checked : diagonalSum_6_2_2.Check nodes 9 := by decide
def diagonalSum_7_0_0 : SumRecipe where
  term := fun i => #[1131,1182,1241,1297,1353,1409,1467,11,1873][i]?.getD 0
  accumulator := fun i => #[11,1131,1183,1242,1298,1354,1410,1468,1468,1875][i]?.getD 0
theorem diagonalSum_7_0_0_checked : diagonalSum_7_0_0.Check nodes 9 := by decide
def diagonalSum_7_0_1 : SumRecipe where
  term := fun i => #[1134,1186,1245,1301,1357,1413,1471,11,11][i]?.getD 0
  accumulator := fun i => #[11,1134,1187,1246,1302,1358,1414,1472,1472,1472][i]?.getD 0
theorem diagonalSum_7_0_1_checked : diagonalSum_7_0_1.Check nodes 9 := by decide
def diagonalSum_7_0_2 : SumRecipe where
  term := fun i => #[1137,1190,1249,1305,1361,1417,11,11,11][i]?.getD 0
  accumulator := fun i => #[11,1137,1191,1250,1306,1362,1418,1418,1418,1418][i]?.getD 0
theorem diagonalSum_7_0_2_checked : diagonalSum_7_0_2.Check nodes 9 := by decide
def diagonalSum_7_1_0 : SumRecipe where
  term := fun i => #[1141,1195,1254,1310,1366,1422,1476,11,11][i]?.getD 0
  accumulator := fun i => #[11,1141,1196,1255,1311,1367,1423,1477,1477,1477][i]?.getD 0
theorem diagonalSum_7_1_0_checked : diagonalSum_7_1_0.Check nodes 9 := by decide
def diagonalSum_7_1_1 : SumRecipe where
  term := fun i => #[1145,1200,1259,1315,1371,1427,1481,11,1879][i]?.getD 0
  accumulator := fun i => #[11,1145,1201,1260,1316,1372,1428,1482,1482,1881][i]?.getD 0
theorem diagonalSum_7_1_1_checked : diagonalSum_7_1_1.Check nodes 9 := by decide
def diagonalSum_7_1_2 : SumRecipe where
  term := fun i => #[1148,1204,1263,1319,1375,1431,11,11,11][i]?.getD 0
  accumulator := fun i => #[11,1148,1205,1264,1320,1376,1432,1432,1432,1432][i]?.getD 0
theorem diagonalSum_7_1_2_checked : diagonalSum_7_1_2.Check nodes 9 := by decide
def diagonalSum_7_2_0 : SumRecipe where
  term := fun i => #[1152,1209,1268,1324,1380,1436,11,11,11][i]?.getD 0
  accumulator := fun i => #[11,1152,1210,1269,1325,1381,1437,1437,1437,1437][i]?.getD 0
theorem diagonalSum_7_2_0_checked : diagonalSum_7_2_0.Check nodes 9 := by decide
def diagonalSum_7_2_1 : SumRecipe where
  term := fun i => #[1155,1213,1272,1328,1384,1440,11,11,11][i]?.getD 0
  accumulator := fun i => #[11,1155,1214,1273,1329,1385,1441,1441,1441,1441][i]?.getD 0
theorem diagonalSum_7_2_1_checked : diagonalSum_7_2_1.Check nodes 9 := by decide
def diagonalSum_7_2_2 : SumRecipe where
  term := fun i => #[1159,1218,1277,1333,1389,1445,1466,11,1873][i]?.getD 0
  accumulator := fun i => #[11,1159,1219,1278,1334,1390,1446,1485,1485,1884][i]?.getD 0
theorem diagonalSum_7_2_2_checked : diagonalSum_7_2_2.Check nodes 9 := by decide
def diagonalSum_8_0_0 : SumRecipe where
  term := fun i => #[1506,1555,1614,1670,1726,1782,1838,1873,11][i]?.getD 0
  accumulator := fun i => #[11,1506,1556,1615,1671,1727,1783,1839,1874,1874][i]?.getD 0
theorem diagonalSum_8_0_0_checked : diagonalSum_8_0_0.Check nodes 9 := by decide
def diagonalSum_8_0_1 : SumRecipe where
  term := fun i => #[1509,1559,1618,1674,1730,1786,1842,11,11][i]?.getD 0
  accumulator := fun i => #[11,1509,1560,1619,1675,1731,1787,1843,1843,1843][i]?.getD 0
theorem diagonalSum_8_0_1_checked : diagonalSum_8_0_1.Check nodes 9 := by decide
def diagonalSum_8_0_2 : SumRecipe where
  term := fun i => #[1512,1563,1622,1678,1734,1790,11,11,11][i]?.getD 0
  accumulator := fun i => #[11,1512,1564,1623,1679,1735,1791,1791,1791,1791][i]?.getD 0
theorem diagonalSum_8_0_2_checked : diagonalSum_8_0_2.Check nodes 9 := by decide
def diagonalSum_8_1_0 : SumRecipe where
  term := fun i => #[1516,1568,1627,1683,1739,1795,1847,11,11][i]?.getD 0
  accumulator := fun i => #[11,1516,1569,1628,1684,1740,1796,1848,1848,1848][i]?.getD 0
theorem diagonalSum_8_1_0_checked : diagonalSum_8_1_0.Check nodes 9 := by decide
def diagonalSum_8_1_1 : SumRecipe where
  term := fun i => #[1520,1573,1632,1688,1744,1800,1852,1879,11][i]?.getD 0
  accumulator := fun i => #[11,1520,1574,1633,1689,1745,1801,1853,1880,1880][i]?.getD 0
theorem diagonalSum_8_1_1_checked : diagonalSum_8_1_1.Check nodes 9 := by decide
def diagonalSum_8_1_2 : SumRecipe where
  term := fun i => #[1523,1577,1636,1692,1748,1804,11,11,11][i]?.getD 0
  accumulator := fun i => #[11,1523,1578,1637,1693,1749,1805,1805,1805,1805][i]?.getD 0
theorem diagonalSum_8_1_2_checked : diagonalSum_8_1_2.Check nodes 9 := by decide
def diagonalSum_8_2_0 : SumRecipe where
  term := fun i => #[1527,1582,1641,1697,1753,1809,11,11,11][i]?.getD 0
  accumulator := fun i => #[11,1527,1583,1642,1698,1754,1810,1810,1810,1810][i]?.getD 0
theorem diagonalSum_8_2_0_checked : diagonalSum_8_2_0.Check nodes 9 := by decide
def diagonalSum_8_2_1 : SumRecipe where
  term := fun i => #[1530,1586,1645,1701,1757,1813,11,11,11][i]?.getD 0
  accumulator := fun i => #[11,1530,1587,1646,1702,1758,1814,1814,1814,1814][i]?.getD 0
theorem diagonalSum_8_2_1_checked : diagonalSum_8_2_1.Check nodes 9 := by decide
def diagonalSum_8_2_2 : SumRecipe where
  term := fun i => #[1534,1591,1650,1706,1762,1818,1837,1873,11][i]?.getD 0
  accumulator := fun i => #[11,1534,1592,1651,1707,1763,1819,1856,1883,1883][i]?.getD 0
theorem diagonalSum_8_2_2_checked : diagonalSum_8_2_2.Check nodes 9 := by decide
def diagonalSums : Fin 9 → Fin 3 → Fin 3 → SumRecipe := ![![![diagonalSum_0_0_0,diagonalSum_0_0_1,diagonalSum_0_0_2],![diagonalSum_0_1_0,diagonalSum_0_1_1,diagonalSum_0_1_2],![diagonalSum_0_2_0,diagonalSum_0_2_1,diagonalSum_0_2_2]],![![diagonalSum_1_0_0,diagonalSum_1_0_1,diagonalSum_1_0_2],![diagonalSum_1_1_0,diagonalSum_1_1_1,diagonalSum_1_1_2],![diagonalSum_1_2_0,diagonalSum_1_2_1,diagonalSum_1_2_2]],![![diagonalSum_2_0_0,diagonalSum_2_0_1,diagonalSum_2_0_2],![diagonalSum_2_1_0,diagonalSum_2_1_1,diagonalSum_2_1_2],![diagonalSum_2_2_0,diagonalSum_2_2_1,diagonalSum_2_2_2]],![![diagonalSum_3_0_0,diagonalSum_3_0_1,diagonalSum_3_0_2],![diagonalSum_3_1_0,diagonalSum_3_1_1,diagonalSum_3_1_2],![diagonalSum_3_2_0,diagonalSum_3_2_1,diagonalSum_3_2_2]],![![diagonalSum_4_0_0,diagonalSum_4_0_1,diagonalSum_4_0_2],![diagonalSum_4_1_0,diagonalSum_4_1_1,diagonalSum_4_1_2],![diagonalSum_4_2_0,diagonalSum_4_2_1,diagonalSum_4_2_2]],![![diagonalSum_5_0_0,diagonalSum_5_0_1,diagonalSum_5_0_2],![diagonalSum_5_1_0,diagonalSum_5_1_1,diagonalSum_5_1_2],![diagonalSum_5_2_0,diagonalSum_5_2_1,diagonalSum_5_2_2]],![![diagonalSum_6_0_0,diagonalSum_6_0_1,diagonalSum_6_0_2],![diagonalSum_6_1_0,diagonalSum_6_1_1,diagonalSum_6_1_2],![diagonalSum_6_2_0,diagonalSum_6_2_1,diagonalSum_6_2_2]],![![diagonalSum_7_0_0,diagonalSum_7_0_1,diagonalSum_7_0_2],![diagonalSum_7_1_0,diagonalSum_7_1_1,diagonalSum_7_1_2],![diagonalSum_7_2_0,diagonalSum_7_2_1,diagonalSum_7_2_2]],![![diagonalSum_8_0_0,diagonalSum_8_0_1,diagonalSum_8_0_2],![diagonalSum_8_1_0,diagonalSum_8_1_1,diagonalSum_8_1_2],![diagonalSum_8_2_0,diagonalSum_8_2_1,diagonalSum_8_2_2]]]
theorem diagonal_sums_checked (i : Fin 9) (a b : Fin 3) :
    (diagonalSums i a b).Check nodes 9 := by
  fin_cases i <;> fin_cases a <;> fin_cases b
  · exact diagonalSum_0_0_0_checked
  · exact diagonalSum_0_0_1_checked
  · exact diagonalSum_0_0_2_checked
  · exact diagonalSum_0_1_0_checked
  · exact diagonalSum_0_1_1_checked
  · exact diagonalSum_0_1_2_checked
  · exact diagonalSum_0_2_0_checked
  · exact diagonalSum_0_2_1_checked
  · exact diagonalSum_0_2_2_checked
  · exact diagonalSum_1_0_0_checked
  · exact diagonalSum_1_0_1_checked
  · exact diagonalSum_1_0_2_checked
  · exact diagonalSum_1_1_0_checked
  · exact diagonalSum_1_1_1_checked
  · exact diagonalSum_1_1_2_checked
  · exact diagonalSum_1_2_0_checked
  · exact diagonalSum_1_2_1_checked
  · exact diagonalSum_1_2_2_checked
  · exact diagonalSum_2_0_0_checked
  · exact diagonalSum_2_0_1_checked
  · exact diagonalSum_2_0_2_checked
  · exact diagonalSum_2_1_0_checked
  · exact diagonalSum_2_1_1_checked
  · exact diagonalSum_2_1_2_checked
  · exact diagonalSum_2_2_0_checked
  · exact diagonalSum_2_2_1_checked
  · exact diagonalSum_2_2_2_checked
  · exact diagonalSum_3_0_0_checked
  · exact diagonalSum_3_0_1_checked
  · exact diagonalSum_3_0_2_checked
  · exact diagonalSum_3_1_0_checked
  · exact diagonalSum_3_1_1_checked
  · exact diagonalSum_3_1_2_checked
  · exact diagonalSum_3_2_0_checked
  · exact diagonalSum_3_2_1_checked
  · exact diagonalSum_3_2_2_checked
  · exact diagonalSum_4_0_0_checked
  · exact diagonalSum_4_0_1_checked
  · exact diagonalSum_4_0_2_checked
  · exact diagonalSum_4_1_0_checked
  · exact diagonalSum_4_1_1_checked
  · exact diagonalSum_4_1_2_checked
  · exact diagonalSum_4_2_0_checked
  · exact diagonalSum_4_2_1_checked
  · exact diagonalSum_4_2_2_checked
  · exact diagonalSum_5_0_0_checked
  · exact diagonalSum_5_0_1_checked
  · exact diagonalSum_5_0_2_checked
  · exact diagonalSum_5_1_0_checked
  · exact diagonalSum_5_1_1_checked
  · exact diagonalSum_5_1_2_checked
  · exact diagonalSum_5_2_0_checked
  · exact diagonalSum_5_2_1_checked
  · exact diagonalSum_5_2_2_checked
  · exact diagonalSum_6_0_0_checked
  · exact diagonalSum_6_0_1_checked
  · exact diagonalSum_6_0_2_checked
  · exact diagonalSum_6_1_0_checked
  · exact diagonalSum_6_1_1_checked
  · exact diagonalSum_6_1_2_checked
  · exact diagonalSum_6_2_0_checked
  · exact diagonalSum_6_2_1_checked
  · exact diagonalSum_6_2_2_checked
  · exact diagonalSum_7_0_0_checked
  · exact diagonalSum_7_0_1_checked
  · exact diagonalSum_7_0_2_checked
  · exact diagonalSum_7_1_0_checked
  · exact diagonalSum_7_1_1_checked
  · exact diagonalSum_7_1_2_checked
  · exact diagonalSum_7_2_0_checked
  · exact diagonalSum_7_2_1_checked
  · exact diagonalSum_7_2_2_checked
  · exact diagonalSum_8_0_0_checked
  · exact diagonalSum_8_0_1_checked
  · exact diagonalSum_8_0_2_checked
  · exact diagonalSum_8_1_0_checked
  · exact diagonalSum_8_1_1_checked
  · exact diagonalSum_8_1_2_checked
  · exact diagonalSum_8_2_0_checked
  · exact diagonalSum_8_2_1_checked
  · exact diagonalSum_8_2_2_checked
theorem diagonal_sum_term (i j : Fin 9) (a b : Fin 3) :
    (diagonalSums i a b).term j =
      if i = j then 11 else (pairRecipes (pairIndex i j)).block a b := by
  revert i j a b; decide
theorem diagonal_sum_output (i : Fin 9) (a b : Fin 3) :
    (diagonalSums i a b).accumulator 9 = laplacianIndices (flatIndex (i,a)) (flatIndex (i,b)) := by
  revert i a b; decide
theorem off_diagonal_checked (i j : Fin 9) (a b : Fin 3) (h : i ≠ j) :
    ExtendedSmartMulCheck nodes ((pairRecipes (pairIndex i j)).block a b) 18
      (laplacianIndices (flatIndex (i,a)) (flatIndex (j,b))) := by
  revert i j a b; decide
theorem literal_zero (values : ℕ → ℝ) : value values nodes 11 = 0 :=
  zeroAt_sound values nodes 11 (by decide)
theorem literal_minus_one (values : ℕ → ℝ) : value values nodes 18 = -1 := by
  simpa using value_constant values nodes 18 (-1) 1 (by decide)
theorem laplacian_entry_sound (r : ℝ) (ia jb : Fin 9 × Fin 3) :
    value (parameterInputs r) nodes (laplacianIndices (flatIndex ia) (flatIndex jb)) =
      blockLaplacian (fun i j => coulombPairBlock (candidateAt r i-candidateAt r j)) ia jb := by
  have heq := pair_hessian_of_entries (candidateAt r)
    (fun ia jb => value (parameterInputs r) nodes (laplacianIndices (flatIndex ia) (flatIndex jb)))
  apply congrFun (congrFun (heq ?_ ?_) ia) jb
  · intro i a b
    rw [← diagonal_sum_output, SumRecipe.sound_fin _ _ _ _ (diagonal_sums_checked i a b)]
    apply Finset.sum_congr rfl
    intro j _
    rw [diagonal_sum_term]
    by_cases hij : i = j
    · subst j
      simp [literal_zero, coulombPairBlock]
    · rw [if_neg hij, unordered_pair_block_sound r i j hij]
  · intro i j a b hij
    rw [extendedSmartMul_sound _ _ _ _ _ (off_diagonal_checked i j a b hij),
      unordered_pair_block_sound r i j hij, literal_minus_one]
    ring
def radialSum_0 : SumRecipe where
  term := fun i => #[11,62,109,207,368,591,852,1164,1539][i]?.getD 0
  accumulator := fun i => #[11,11,62,110,208,369,592,853,1165,1540][i]?.getD 0
theorem radialSum_0_checked : radialSum_0.Check nodes 9 := by decide
def radialSum_1 : SumRecipe where
  term := fun i => #[62,11,171,262,426,646,906,1224,1597][i]?.getD 0
  accumulator := fun i => #[11,62,62,173,264,428,648,908,1226,1599][i]?.getD 0
theorem radialSum_1_checked : radialSum_1.Check nodes 9 := by decide
def radialSum_2 : SumRecipe where
  term := fun i => #[109,171,11,321,485,705,963,1283,1656][i]?.getD 0
  accumulator := fun i => #[11,109,172,172,323,487,707,965,1285,1658][i]?.getD 0
theorem radialSum_2_checked : radialSum_2.Check nodes 9 := by decide
def radialSum_3 : SumRecipe where
  term := fun i => #[207,262,321,11,544,761,1001,1339,1712][i]?.getD 0
  accumulator := fun i => #[11,207,263,322,322,546,763,1003,1341,1714][i]?.getD 0
theorem radialSum_3_checked : radialSum_3.Check nodes 9 := by decide
def radialSum_4 : SumRecipe where
  term := fun i => #[368,426,485,544,11,817,1057,1395,1768][i]?.getD 0
  accumulator := fun i => #[11,368,427,486,545,545,819,1059,1397,1770][i]?.getD 0
theorem radialSum_4_checked : radialSum_4.Check nodes 9 := by decide
def radialSum_5 : SumRecipe where
  term := fun i => #[591,646,705,761,817,11,1113,1451,1824][i]?.getD 0
  accumulator := fun i => #[11,591,647,706,762,818,818,1115,1453,1826][i]?.getD 0
theorem radialSum_5_checked : radialSum_5.Check nodes 9 := by decide
def radialSum_6 : SumRecipe where
  term := fun i => #[852,906,963,1001,1057,1113,11,1490,1861][i]?.getD 0
  accumulator := fun i => #[11,852,907,964,1002,1058,1114,1114,1492,1863][i]?.getD 0
theorem radialSum_6_checked : radialSum_6.Check nodes 9 := by decide
def radialSum_7 : SumRecipe where
  term := fun i => #[1164,1224,1283,1339,1395,1451,1490,11,1887][i]?.getD 0
  accumulator := fun i => #[11,1164,1225,1284,1340,1396,1452,1491,1491,1889][i]?.getD 0
theorem radialSum_7_checked : radialSum_7.Check nodes 9 := by decide
def radialSum_8 : SumRecipe where
  term := fun i => #[1539,1597,1656,1712,1768,1824,1861,1887,11][i]?.getD 0
  accumulator := fun i => #[11,1539,1598,1657,1713,1769,1825,1862,1888,1888][i]?.getD 0
theorem radialSum_8_checked : radialSum_8.Check nodes 9 := by decide
def radialSums : Fin 9 → SumRecipe := ![radialSum_0,radialSum_1,radialSum_2,radialSum_3,radialSum_4,radialSum_5,radialSum_6,radialSum_7,radialSum_8]
theorem radial_sums_checked (i : Fin 9) : (radialSums i).Check nodes 9 := by
  fin_cases i
  · exact radialSum_0_checked
  · exact radialSum_1_checked
  · exact radialSum_2_checked
  · exact radialSum_3_checked
  · exact radialSum_4_checked
  · exact radialSum_5_checked
  · exact radialSum_6_checked
  · exact radialSum_7_checked
  · exact radialSum_8_checked
theorem radial_sum_term (i j : Fin 9) : (radialSums i).term j =
    if i = j then 11 else (halfInverseRecipes (pairIndex i j)).negative := by
  revert i j; decide
theorem radial_sum_output (i : Fin 9) : (radialSums i).accumulator 9 = lambdaIndices i := by
  revert i; decide
theorem radial_entry_sound (r : ℝ) (i : Fin 9) :
    value (parameterInputs r) nodes (lambdaIndices i) = radialCoefficient (candidateAt r) i := by
  rw [← radial_sum_output, SumRecipe.sound_fin _ _ _ _ (radial_sums_checked i)]
  calc
    _ = ∑ j : Fin 9, -(‖candidateAt r i-candidateAt r j‖⁻¹/2) := by
      apply Finset.sum_congr rfl
      intro j _
      rw [radial_sum_term]
      by_cases hij : i = j
      · subst j; simp [literal_zero]
      · rw [if_neg hij, unordered_half_inverse_sound r i j hij]
    _ = _ := by rw [Finset.sum_neg_distrib, ← Finset.sum_div]; simp [radialCoefficient, neg_div]
theorem lagrange_correction_checked (i : Fin 9) :
    ExtendedSmartMulCheck nodes (lambdaIndices i) 18 (lagrangeCorrections i) := by
  revert i; decide
theorem constrained_checked (ia jb : Fin 9 × Fin 3) :
    ExtendedSmartAddCheck nodes (laplacianIndices (flatIndex ia) (flatIndex jb))
      (if ia = jb then lagrangeCorrections ia.1 else 11)
      (constrainedIndices (flatIndex ia) (flatIndex jb)) := by
  revert ia jb; decide
theorem constrained_entry_sound (r : ℝ) (ia jb : Fin 9 × Fin 3) :
    value (parameterInputs r) nodes (constrainedIndices (flatIndex ia) (flatIndex jb)) =
      constrainedHessian (candidateAt r) ia jb := by
  rw [extendedSmartAdd_sound _ _ _ _ _ (constrained_checked ia jb), laplacian_entry_sound]
  by_cases hij : ia = jb
  · subst jb
    rw [if_pos rfl, extendedSmartMul_sound _ _ _ _ _ (lagrange_correction_checked ia.1),
      radial_entry_sound, literal_minus_one]
    simp [constrainedHessian, Matrix.sub_apply, Matrix.diagonal_apply, sub_eq_add_neg]
  · rw [if_neg hij, literal_zero]
    simp [constrainedHessian, Matrix.sub_apply, Matrix.diagonal_apply, hij]
def rotationIndices : Fin 9 → Fin 3 → Fin 3 → ℕ := ![![![11,5,11],![14,11,0],![11,20,11]],![![11,5,113],![14,11,15],![16,111,11]],![![11,5,265],![14,11,15],![17,111,11]],![![11,14,11],![488,11,0],![11,20,11]],![![11,14,113],![488,11,15],![16,111,11]],![![11,14,265],![488,11,15],![17,111,11]],![![11,11,11],![11,11,18],![11,2,11]],![![11,11,19],![11,11,9],![13,12,11]],![![11,11,1926],![11,11,9],![19,12,11]]]
theorem rotations_checked : RotationCheck nodes pointIndices rotationIndices := by decide
theorem rotation_entry_sound (r : ℝ) (ia : Fin 9 × Fin 3) (k : Fin 3) :
    value (parameterInputs r) nodes (rotationIndices ia.1 ia.2 k) =
      rotationColumns (candidateAt r) ia k :=
  rotation_recipe_sound _ nodes pointIndices rotationIndices rotations_checked _
    (coordinate_recipe_sound r nodes coordinate_prefix_checked) ia.1 ia.2 k
def rotationDot_0_0 : DotRecipe where
  left := fun i => #[11,5,11][i]?.getD 0
  right := fun i => #[11,5,11][i]?.getD 0
  product := fun i => #[11,1927,11][i]?.getD 0
  accumulator := fun i => #[11,11,1927,1927][i]?.getD 0
theorem rotationDot_0_0_checked : rotationDot_0_0.ExtendedCheck nodes 3 := by decide
def rotationDot_0_1 : DotRecipe where
  left := fun i => #[11,5,11][i]?.getD 0
  right := fun i => #[14,11,0][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_0_1_checked : rotationDot_0_1.ExtendedCheck nodes 3 := by decide
def rotationDot_0_2 : DotRecipe where
  left := fun i => #[11,5,11][i]?.getD 0
  right := fun i => #[11,20,11][i]?.getD 0
  product := fun i => #[11,1929,11][i]?.getD 0
  accumulator := fun i => #[11,11,1929,1929][i]?.getD 0
theorem rotationDot_0_2_checked : rotationDot_0_2.ExtendedCheck nodes 3 := by decide
def rotationDot_0_3 : DotRecipe where
  left := fun i => #[11,5,11][i]?.getD 0
  right := fun i => #[11,5,113][i]?.getD 0
  product := fun i => #[11,1927,11][i]?.getD 0
  accumulator := fun i => #[11,11,1927,1927][i]?.getD 0
theorem rotationDot_0_3_checked : rotationDot_0_3.ExtendedCheck nodes 3 := by decide
def rotationDot_0_4 : DotRecipe where
  left := fun i => #[11,5,11][i]?.getD 0
  right := fun i => #[14,11,15][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_0_4_checked : rotationDot_0_4.ExtendedCheck nodes 3 := by decide
def rotationDot_0_5 : DotRecipe where
  left := fun i => #[11,5,11][i]?.getD 0
  right := fun i => #[16,111,11][i]?.getD 0
  product := fun i => #[11,1932,11][i]?.getD 0
  accumulator := fun i => #[11,11,1932,1932][i]?.getD 0
theorem rotationDot_0_5_checked : rotationDot_0_5.ExtendedCheck nodes 3 := by decide
def rotationDot_0_6 : DotRecipe where
  left := fun i => #[11,5,11][i]?.getD 0
  right := fun i => #[11,5,265][i]?.getD 0
  product := fun i => #[11,1927,11][i]?.getD 0
  accumulator := fun i => #[11,11,1927,1927][i]?.getD 0
theorem rotationDot_0_6_checked : rotationDot_0_6.ExtendedCheck nodes 3 := by decide
def rotationDot_0_7 : DotRecipe where
  left := fun i => #[11,5,11][i]?.getD 0
  right := fun i => #[14,11,15][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_0_7_checked : rotationDot_0_7.ExtendedCheck nodes 3 := by decide
def rotationDot_0_8 : DotRecipe where
  left := fun i => #[11,5,11][i]?.getD 0
  right := fun i => #[17,111,11][i]?.getD 0
  product := fun i => #[11,1932,11][i]?.getD 0
  accumulator := fun i => #[11,11,1932,1932][i]?.getD 0
theorem rotationDot_0_8_checked : rotationDot_0_8.ExtendedCheck nodes 3 := by decide
def rotationDot_0_9 : DotRecipe where
  left := fun i => #[11,5,11][i]?.getD 0
  right := fun i => #[11,14,11][i]?.getD 0
  product := fun i => #[11,1936,11][i]?.getD 0
  accumulator := fun i => #[11,11,1936,1936][i]?.getD 0
theorem rotationDot_0_9_checked : rotationDot_0_9.ExtendedCheck nodes 3 := by decide
def rotationDot_0_10 : DotRecipe where
  left := fun i => #[11,5,11][i]?.getD 0
  right := fun i => #[488,11,0][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_0_10_checked : rotationDot_0_10.ExtendedCheck nodes 3 := by decide
def rotationDot_0_11 : DotRecipe where
  left := fun i => #[11,5,11][i]?.getD 0
  right := fun i => #[11,20,11][i]?.getD 0
  product := fun i => #[11,1929,11][i]?.getD 0
  accumulator := fun i => #[11,11,1929,1929][i]?.getD 0
theorem rotationDot_0_11_checked : rotationDot_0_11.ExtendedCheck nodes 3 := by decide
def rotationDot_0_12 : DotRecipe where
  left := fun i => #[11,5,11][i]?.getD 0
  right := fun i => #[11,14,113][i]?.getD 0
  product := fun i => #[11,1936,11][i]?.getD 0
  accumulator := fun i => #[11,11,1936,1936][i]?.getD 0
theorem rotationDot_0_12_checked : rotationDot_0_12.ExtendedCheck nodes 3 := by decide
def rotationDot_0_13 : DotRecipe where
  left := fun i => #[11,5,11][i]?.getD 0
  right := fun i => #[488,11,15][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_0_13_checked : rotationDot_0_13.ExtendedCheck nodes 3 := by decide
def rotationDot_0_14 : DotRecipe where
  left := fun i => #[11,5,11][i]?.getD 0
  right := fun i => #[16,111,11][i]?.getD 0
  product := fun i => #[11,1932,11][i]?.getD 0
  accumulator := fun i => #[11,11,1932,1932][i]?.getD 0
theorem rotationDot_0_14_checked : rotationDot_0_14.ExtendedCheck nodes 3 := by decide
def rotationDot_0_15 : DotRecipe where
  left := fun i => #[11,5,11][i]?.getD 0
  right := fun i => #[11,14,265][i]?.getD 0
  product := fun i => #[11,1936,11][i]?.getD 0
  accumulator := fun i => #[11,11,1936,1936][i]?.getD 0
theorem rotationDot_0_15_checked : rotationDot_0_15.ExtendedCheck nodes 3 := by decide
def rotationDot_0_16 : DotRecipe where
  left := fun i => #[11,5,11][i]?.getD 0
  right := fun i => #[488,11,15][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_0_16_checked : rotationDot_0_16.ExtendedCheck nodes 3 := by decide
def rotationDot_0_17 : DotRecipe where
  left := fun i => #[11,5,11][i]?.getD 0
  right := fun i => #[17,111,11][i]?.getD 0
  product := fun i => #[11,1932,11][i]?.getD 0
  accumulator := fun i => #[11,11,1932,1932][i]?.getD 0
theorem rotationDot_0_17_checked : rotationDot_0_17.ExtendedCheck nodes 3 := by decide
def rotationDot_0_18 : DotRecipe where
  left := fun i => #[11,5,11][i]?.getD 0
  right := fun i => #[11,11,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_0_18_checked : rotationDot_0_18.ExtendedCheck nodes 3 := by decide
def rotationDot_0_19 : DotRecipe where
  left := fun i => #[11,5,11][i]?.getD 0
  right := fun i => #[11,11,18][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_0_19_checked : rotationDot_0_19.ExtendedCheck nodes 3 := by decide
def rotationDot_0_20 : DotRecipe where
  left := fun i => #[11,5,11][i]?.getD 0
  right := fun i => #[11,2,11][i]?.getD 0
  product := fun i => #[11,5,11][i]?.getD 0
  accumulator := fun i => #[11,11,5,5][i]?.getD 0
theorem rotationDot_0_20_checked : rotationDot_0_20.ExtendedCheck nodes 3 := by decide
def rotationDot_0_21 : DotRecipe where
  left := fun i => #[11,5,11][i]?.getD 0
  right := fun i => #[11,11,19][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_0_21_checked : rotationDot_0_21.ExtendedCheck nodes 3 := by decide
def rotationDot_0_22 : DotRecipe where
  left := fun i => #[11,5,11][i]?.getD 0
  right := fun i => #[11,11,9][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_0_22_checked : rotationDot_0_22.ExtendedCheck nodes 3 := by decide
def rotationDot_0_23 : DotRecipe where
  left := fun i => #[11,5,11][i]?.getD 0
  right := fun i => #[13,12,11][i]?.getD 0
  product := fun i => #[11,1944,11][i]?.getD 0
  accumulator := fun i => #[11,11,1944,1944][i]?.getD 0
theorem rotationDot_0_23_checked : rotationDot_0_23.ExtendedCheck nodes 3 := by decide
def rotationDot_0_24 : DotRecipe where
  left := fun i => #[11,5,11][i]?.getD 0
  right := fun i => #[11,11,1926][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_0_24_checked : rotationDot_0_24.ExtendedCheck nodes 3 := by decide
def rotationDot_0_25 : DotRecipe where
  left := fun i => #[11,5,11][i]?.getD 0
  right := fun i => #[11,11,9][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_0_25_checked : rotationDot_0_25.ExtendedCheck nodes 3 := by decide
def rotationDot_0_26 : DotRecipe where
  left := fun i => #[11,5,11][i]?.getD 0
  right := fun i => #[19,12,11][i]?.getD 0
  product := fun i => #[11,1944,11][i]?.getD 0
  accumulator := fun i => #[11,11,1944,1944][i]?.getD 0
theorem rotationDot_0_26_checked : rotationDot_0_26.ExtendedCheck nodes 3 := by decide
def rotationDotsRow0 : Array DotRecipe := #[rotationDot_0_0,rotationDot_0_1,rotationDot_0_2,rotationDot_0_3,rotationDot_0_4,rotationDot_0_5,rotationDot_0_6,rotationDot_0_7,rotationDot_0_8,rotationDot_0_9,rotationDot_0_10,rotationDot_0_11,rotationDot_0_12,rotationDot_0_13,rotationDot_0_14,rotationDot_0_15,rotationDot_0_16,rotationDot_0_17,rotationDot_0_18,rotationDot_0_19,rotationDot_0_20,rotationDot_0_21,rotationDot_0_22,rotationDot_0_23,rotationDot_0_24,rotationDot_0_25,rotationDot_0_26]
theorem rotationDotsRow0_checked (j : Fin 27) :
    (rotationDotsRow0[j.val]?.getD rotationDot_0_0).ExtendedCheck nodes 3 := by
  fin_cases j
  · exact rotationDot_0_0_checked
  · exact rotationDot_0_1_checked
  · exact rotationDot_0_2_checked
  · exact rotationDot_0_3_checked
  · exact rotationDot_0_4_checked
  · exact rotationDot_0_5_checked
  · exact rotationDot_0_6_checked
  · exact rotationDot_0_7_checked
  · exact rotationDot_0_8_checked
  · exact rotationDot_0_9_checked
  · exact rotationDot_0_10_checked
  · exact rotationDot_0_11_checked
  · exact rotationDot_0_12_checked
  · exact rotationDot_0_13_checked
  · exact rotationDot_0_14_checked
  · exact rotationDot_0_15_checked
  · exact rotationDot_0_16_checked
  · exact rotationDot_0_17_checked
  · exact rotationDot_0_18_checked
  · exact rotationDot_0_19_checked
  · exact rotationDot_0_20_checked
  · exact rotationDot_0_21_checked
  · exact rotationDot_0_22_checked
  · exact rotationDot_0_23_checked
  · exact rotationDot_0_24_checked
  · exact rotationDot_0_25_checked
  · exact rotationDot_0_26_checked
def rotationDot_1_0 : DotRecipe where
  left := fun i => #[14,11,0][i]?.getD 0
  right := fun i => #[11,5,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_1_0_checked : rotationDot_1_0.ExtendedCheck nodes 3 := by decide
def rotationDot_1_1 : DotRecipe where
  left := fun i => #[14,11,0][i]?.getD 0
  right := fun i => #[14,11,0][i]?.getD 0
  product := fun i => #[822,11,1][i]?.getD 0
  accumulator := fun i => #[11,822,822,1947][i]?.getD 0
theorem rotationDot_1_1_checked : rotationDot_1_1.ExtendedCheck nodes 3 := by decide
def rotationDot_1_2 : DotRecipe where
  left := fun i => #[14,11,0][i]?.getD 0
  right := fun i => #[11,20,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_1_2_checked : rotationDot_1_2.ExtendedCheck nodes 3 := by decide
def rotationDot_1_3 : DotRecipe where
  left := fun i => #[14,11,0][i]?.getD 0
  right := fun i => #[11,5,113][i]?.getD 0
  product := fun i => #[11,11,1949][i]?.getD 0
  accumulator := fun i => #[11,11,11,1949][i]?.getD 0
theorem rotationDot_1_3_checked : rotationDot_1_3.ExtendedCheck nodes 3 := by decide
def rotationDot_1_4 : DotRecipe where
  left := fun i => #[14,11,0][i]?.getD 0
  right := fun i => #[14,11,15][i]?.getD 0
  product := fun i => #[822,11,1951][i]?.getD 0
  accumulator := fun i => #[11,822,822,1952][i]?.getD 0
theorem rotationDot_1_4_checked : rotationDot_1_4.ExtendedCheck nodes 3 := by decide
def rotationDot_1_5 : DotRecipe where
  left := fun i => #[14,11,0][i]?.getD 0
  right := fun i => #[16,111,11][i]?.getD 0
  product := fun i => #[1954,11,11][i]?.getD 0
  accumulator := fun i => #[11,1954,1954,1954][i]?.getD 0
theorem rotationDot_1_5_checked : rotationDot_1_5.ExtendedCheck nodes 3 := by decide
def rotationDot_1_6 : DotRecipe where
  left := fun i => #[14,11,0][i]?.getD 0
  right := fun i => #[11,5,265][i]?.getD 0
  product := fun i => #[11,11,1956][i]?.getD 0
  accumulator := fun i => #[11,11,11,1956][i]?.getD 0
theorem rotationDot_1_6_checked : rotationDot_1_6.ExtendedCheck nodes 3 := by decide
def rotationDot_1_7 : DotRecipe where
  left := fun i => #[14,11,0][i]?.getD 0
  right := fun i => #[14,11,15][i]?.getD 0
  product := fun i => #[822,11,1951][i]?.getD 0
  accumulator := fun i => #[11,822,822,1952][i]?.getD 0
theorem rotationDot_1_7_checked : rotationDot_1_7.ExtendedCheck nodes 3 := by decide
def rotationDot_1_8 : DotRecipe where
  left := fun i => #[14,11,0][i]?.getD 0
  right := fun i => #[17,111,11][i]?.getD 0
  product := fun i => #[1959,11,11][i]?.getD 0
  accumulator := fun i => #[11,1959,1959,1959][i]?.getD 0
theorem rotationDot_1_8_checked : rotationDot_1_8.ExtendedCheck nodes 3 := by decide
def rotationDot_1_9 : DotRecipe where
  left := fun i => #[14,11,0][i]?.getD 0
  right := fun i => #[11,14,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_1_9_checked : rotationDot_1_9.ExtendedCheck nodes 3 := by decide
def rotationDot_1_10 : DotRecipe where
  left := fun i => #[14,11,0][i]?.getD 0
  right := fun i => #[488,11,0][i]?.getD 0
  product := fun i => #[1961,11,1][i]?.getD 0
  accumulator := fun i => #[11,1961,1961,1962][i]?.getD 0
theorem rotationDot_1_10_checked : rotationDot_1_10.ExtendedCheck nodes 3 := by decide
def rotationDot_1_11 : DotRecipe where
  left := fun i => #[14,11,0][i]?.getD 0
  right := fun i => #[11,20,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_1_11_checked : rotationDot_1_11.ExtendedCheck nodes 3 := by decide
def rotationDot_1_12 : DotRecipe where
  left := fun i => #[14,11,0][i]?.getD 0
  right := fun i => #[11,14,113][i]?.getD 0
  product := fun i => #[11,11,1949][i]?.getD 0
  accumulator := fun i => #[11,11,11,1949][i]?.getD 0
theorem rotationDot_1_12_checked : rotationDot_1_12.ExtendedCheck nodes 3 := by decide
def rotationDot_1_13 : DotRecipe where
  left := fun i => #[14,11,0][i]?.getD 0
  right := fun i => #[488,11,15][i]?.getD 0
  product := fun i => #[1961,11,1951][i]?.getD 0
  accumulator := fun i => #[11,1961,1961,1965][i]?.getD 0
theorem rotationDot_1_13_checked : rotationDot_1_13.ExtendedCheck nodes 3 := by decide
def rotationDot_1_14 : DotRecipe where
  left := fun i => #[14,11,0][i]?.getD 0
  right := fun i => #[16,111,11][i]?.getD 0
  product := fun i => #[1954,11,11][i]?.getD 0
  accumulator := fun i => #[11,1954,1954,1954][i]?.getD 0
theorem rotationDot_1_14_checked : rotationDot_1_14.ExtendedCheck nodes 3 := by decide
def rotationDot_1_15 : DotRecipe where
  left := fun i => #[14,11,0][i]?.getD 0
  right := fun i => #[11,14,265][i]?.getD 0
  product := fun i => #[11,11,1956][i]?.getD 0
  accumulator := fun i => #[11,11,11,1956][i]?.getD 0
theorem rotationDot_1_15_checked : rotationDot_1_15.ExtendedCheck nodes 3 := by decide
def rotationDot_1_16 : DotRecipe where
  left := fun i => #[14,11,0][i]?.getD 0
  right := fun i => #[488,11,15][i]?.getD 0
  product := fun i => #[1961,11,1951][i]?.getD 0
  accumulator := fun i => #[11,1961,1961,1965][i]?.getD 0
theorem rotationDot_1_16_checked : rotationDot_1_16.ExtendedCheck nodes 3 := by decide
def rotationDot_1_17 : DotRecipe where
  left := fun i => #[14,11,0][i]?.getD 0
  right := fun i => #[17,111,11][i]?.getD 0
  product := fun i => #[1959,11,11][i]?.getD 0
  accumulator := fun i => #[11,1959,1959,1959][i]?.getD 0
theorem rotationDot_1_17_checked : rotationDot_1_17.ExtendedCheck nodes 3 := by decide
def rotationDot_1_18 : DotRecipe where
  left := fun i => #[14,11,0][i]?.getD 0
  right := fun i => #[11,11,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_1_18_checked : rotationDot_1_18.ExtendedCheck nodes 3 := by decide
def rotationDot_1_19 : DotRecipe where
  left := fun i => #[14,11,0][i]?.getD 0
  right := fun i => #[11,11,18][i]?.getD 0
  product := fun i => #[11,11,1971][i]?.getD 0
  accumulator := fun i => #[11,11,11,1971][i]?.getD 0
theorem rotationDot_1_19_checked : rotationDot_1_19.ExtendedCheck nodes 3 := by decide
def rotationDot_1_20 : DotRecipe where
  left := fun i => #[14,11,0][i]?.getD 0
  right := fun i => #[11,2,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_1_20_checked : rotationDot_1_20.ExtendedCheck nodes 3 := by decide
def rotationDot_1_21 : DotRecipe where
  left := fun i => #[14,11,0][i]?.getD 0
  right := fun i => #[11,11,19][i]?.getD 0
  product := fun i => #[11,11,1973][i]?.getD 0
  accumulator := fun i => #[11,11,11,1973][i]?.getD 0
theorem rotationDot_1_21_checked : rotationDot_1_21.ExtendedCheck nodes 3 := by decide
def rotationDot_1_22 : DotRecipe where
  left := fun i => #[14,11,0][i]?.getD 0
  right := fun i => #[11,11,9][i]?.getD 0
  product := fun i => #[11,11,1975][i]?.getD 0
  accumulator := fun i => #[11,11,11,1975][i]?.getD 0
theorem rotationDot_1_22_checked : rotationDot_1_22.ExtendedCheck nodes 3 := by decide
def rotationDot_1_23 : DotRecipe where
  left := fun i => #[14,11,0][i]?.getD 0
  right := fun i => #[13,12,11][i]?.getD 0
  product := fun i => #[1977,11,11][i]?.getD 0
  accumulator := fun i => #[11,1977,1977,1977][i]?.getD 0
theorem rotationDot_1_23_checked : rotationDot_1_23.ExtendedCheck nodes 3 := by decide
def rotationDot_1_24 : DotRecipe where
  left := fun i => #[14,11,0][i]?.getD 0
  right := fun i => #[11,11,1926][i]?.getD 0
  product := fun i => #[11,11,1979][i]?.getD 0
  accumulator := fun i => #[11,11,11,1979][i]?.getD 0
theorem rotationDot_1_24_checked : rotationDot_1_24.ExtendedCheck nodes 3 := by decide
def rotationDot_1_25 : DotRecipe where
  left := fun i => #[14,11,0][i]?.getD 0
  right := fun i => #[11,11,9][i]?.getD 0
  product := fun i => #[11,11,1975][i]?.getD 0
  accumulator := fun i => #[11,11,11,1975][i]?.getD 0
theorem rotationDot_1_25_checked : rotationDot_1_25.ExtendedCheck nodes 3 := by decide
def rotationDot_1_26 : DotRecipe where
  left := fun i => #[14,11,0][i]?.getD 0
  right := fun i => #[19,12,11][i]?.getD 0
  product := fun i => #[1982,11,11][i]?.getD 0
  accumulator := fun i => #[11,1982,1982,1982][i]?.getD 0
theorem rotationDot_1_26_checked : rotationDot_1_26.ExtendedCheck nodes 3 := by decide
def rotationDotsRow1 : Array DotRecipe := #[rotationDot_1_0,rotationDot_1_1,rotationDot_1_2,rotationDot_1_3,rotationDot_1_4,rotationDot_1_5,rotationDot_1_6,rotationDot_1_7,rotationDot_1_8,rotationDot_1_9,rotationDot_1_10,rotationDot_1_11,rotationDot_1_12,rotationDot_1_13,rotationDot_1_14,rotationDot_1_15,rotationDot_1_16,rotationDot_1_17,rotationDot_1_18,rotationDot_1_19,rotationDot_1_20,rotationDot_1_21,rotationDot_1_22,rotationDot_1_23,rotationDot_1_24,rotationDot_1_25,rotationDot_1_26]
theorem rotationDotsRow1_checked (j : Fin 27) :
    (rotationDotsRow1[j.val]?.getD rotationDot_0_0).ExtendedCheck nodes 3 := by
  fin_cases j
  · exact rotationDot_1_0_checked
  · exact rotationDot_1_1_checked
  · exact rotationDot_1_2_checked
  · exact rotationDot_1_3_checked
  · exact rotationDot_1_4_checked
  · exact rotationDot_1_5_checked
  · exact rotationDot_1_6_checked
  · exact rotationDot_1_7_checked
  · exact rotationDot_1_8_checked
  · exact rotationDot_1_9_checked
  · exact rotationDot_1_10_checked
  · exact rotationDot_1_11_checked
  · exact rotationDot_1_12_checked
  · exact rotationDot_1_13_checked
  · exact rotationDot_1_14_checked
  · exact rotationDot_1_15_checked
  · exact rotationDot_1_16_checked
  · exact rotationDot_1_17_checked
  · exact rotationDot_1_18_checked
  · exact rotationDot_1_19_checked
  · exact rotationDot_1_20_checked
  · exact rotationDot_1_21_checked
  · exact rotationDot_1_22_checked
  · exact rotationDot_1_23_checked
  · exact rotationDot_1_24_checked
  · exact rotationDot_1_25_checked
  · exact rotationDot_1_26_checked
def rotationDot_2_0 : DotRecipe where
  left := fun i => #[11,20,11][i]?.getD 0
  right := fun i => #[11,5,11][i]?.getD 0
  product := fun i => #[11,1984,11][i]?.getD 0
  accumulator := fun i => #[11,11,1984,1984][i]?.getD 0
theorem rotationDot_2_0_checked : rotationDot_2_0.ExtendedCheck nodes 3 := by decide
def rotationDot_2_1 : DotRecipe where
  left := fun i => #[11,20,11][i]?.getD 0
  right := fun i => #[14,11,0][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_2_1_checked : rotationDot_2_1.ExtendedCheck nodes 3 := by decide
def rotationDot_2_2 : DotRecipe where
  left := fun i => #[11,20,11][i]?.getD 0
  right := fun i => #[11,20,11][i]?.getD 0
  product := fun i => #[11,1986,11][i]?.getD 0
  accumulator := fun i => #[11,11,1986,1986][i]?.getD 0
theorem rotationDot_2_2_checked : rotationDot_2_2.ExtendedCheck nodes 3 := by decide
def rotationDot_2_3 : DotRecipe where
  left := fun i => #[11,20,11][i]?.getD 0
  right := fun i => #[11,5,113][i]?.getD 0
  product := fun i => #[11,1984,11][i]?.getD 0
  accumulator := fun i => #[11,11,1984,1984][i]?.getD 0
theorem rotationDot_2_3_checked : rotationDot_2_3.ExtendedCheck nodes 3 := by decide
def rotationDot_2_4 : DotRecipe where
  left := fun i => #[11,20,11][i]?.getD 0
  right := fun i => #[14,11,15][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_2_4_checked : rotationDot_2_4.ExtendedCheck nodes 3 := by decide
def rotationDot_2_5 : DotRecipe where
  left := fun i => #[11,20,11][i]?.getD 0
  right := fun i => #[16,111,11][i]?.getD 0
  product := fun i => #[11,1989,11][i]?.getD 0
  accumulator := fun i => #[11,11,1989,1989][i]?.getD 0
theorem rotationDot_2_5_checked : rotationDot_2_5.ExtendedCheck nodes 3 := by decide
def rotationDot_2_6 : DotRecipe where
  left := fun i => #[11,20,11][i]?.getD 0
  right := fun i => #[11,5,265][i]?.getD 0
  product := fun i => #[11,1984,11][i]?.getD 0
  accumulator := fun i => #[11,11,1984,1984][i]?.getD 0
theorem rotationDot_2_6_checked : rotationDot_2_6.ExtendedCheck nodes 3 := by decide
def rotationDot_2_7 : DotRecipe where
  left := fun i => #[11,20,11][i]?.getD 0
  right := fun i => #[14,11,15][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_2_7_checked : rotationDot_2_7.ExtendedCheck nodes 3 := by decide
def rotationDot_2_8 : DotRecipe where
  left := fun i => #[11,20,11][i]?.getD 0
  right := fun i => #[17,111,11][i]?.getD 0
  product := fun i => #[11,1989,11][i]?.getD 0
  accumulator := fun i => #[11,11,1989,1989][i]?.getD 0
theorem rotationDot_2_8_checked : rotationDot_2_8.ExtendedCheck nodes 3 := by decide
def rotationDot_2_9 : DotRecipe where
  left := fun i => #[11,20,11][i]?.getD 0
  right := fun i => #[11,14,11][i]?.getD 0
  product := fun i => #[11,1993,11][i]?.getD 0
  accumulator := fun i => #[11,11,1993,1993][i]?.getD 0
theorem rotationDot_2_9_checked : rotationDot_2_9.ExtendedCheck nodes 3 := by decide
def rotationDot_2_10 : DotRecipe where
  left := fun i => #[11,20,11][i]?.getD 0
  right := fun i => #[488,11,0][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_2_10_checked : rotationDot_2_10.ExtendedCheck nodes 3 := by decide
def rotationDot_2_11 : DotRecipe where
  left := fun i => #[11,20,11][i]?.getD 0
  right := fun i => #[11,20,11][i]?.getD 0
  product := fun i => #[11,1986,11][i]?.getD 0
  accumulator := fun i => #[11,11,1986,1986][i]?.getD 0
theorem rotationDot_2_11_checked : rotationDot_2_11.ExtendedCheck nodes 3 := by decide
def rotationDot_2_12 : DotRecipe where
  left := fun i => #[11,20,11][i]?.getD 0
  right := fun i => #[11,14,113][i]?.getD 0
  product := fun i => #[11,1993,11][i]?.getD 0
  accumulator := fun i => #[11,11,1993,1993][i]?.getD 0
theorem rotationDot_2_12_checked : rotationDot_2_12.ExtendedCheck nodes 3 := by decide
def rotationDot_2_13 : DotRecipe where
  left := fun i => #[11,20,11][i]?.getD 0
  right := fun i => #[488,11,15][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_2_13_checked : rotationDot_2_13.ExtendedCheck nodes 3 := by decide
def rotationDot_2_14 : DotRecipe where
  left := fun i => #[11,20,11][i]?.getD 0
  right := fun i => #[16,111,11][i]?.getD 0
  product := fun i => #[11,1989,11][i]?.getD 0
  accumulator := fun i => #[11,11,1989,1989][i]?.getD 0
theorem rotationDot_2_14_checked : rotationDot_2_14.ExtendedCheck nodes 3 := by decide
def rotationDot_2_15 : DotRecipe where
  left := fun i => #[11,20,11][i]?.getD 0
  right := fun i => #[11,14,265][i]?.getD 0
  product := fun i => #[11,1993,11][i]?.getD 0
  accumulator := fun i => #[11,11,1993,1993][i]?.getD 0
theorem rotationDot_2_15_checked : rotationDot_2_15.ExtendedCheck nodes 3 := by decide
def rotationDot_2_16 : DotRecipe where
  left := fun i => #[11,20,11][i]?.getD 0
  right := fun i => #[488,11,15][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_2_16_checked : rotationDot_2_16.ExtendedCheck nodes 3 := by decide
def rotationDot_2_17 : DotRecipe where
  left := fun i => #[11,20,11][i]?.getD 0
  right := fun i => #[17,111,11][i]?.getD 0
  product := fun i => #[11,1989,11][i]?.getD 0
  accumulator := fun i => #[11,11,1989,1989][i]?.getD 0
theorem rotationDot_2_17_checked : rotationDot_2_17.ExtendedCheck nodes 3 := by decide
def rotationDot_2_18 : DotRecipe where
  left := fun i => #[11,20,11][i]?.getD 0
  right := fun i => #[11,11,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_2_18_checked : rotationDot_2_18.ExtendedCheck nodes 3 := by decide
def rotationDot_2_19 : DotRecipe where
  left := fun i => #[11,20,11][i]?.getD 0
  right := fun i => #[11,11,18][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_2_19_checked : rotationDot_2_19.ExtendedCheck nodes 3 := by decide
def rotationDot_2_20 : DotRecipe where
  left := fun i => #[11,20,11][i]?.getD 0
  right := fun i => #[11,2,11][i]?.getD 0
  product := fun i => #[11,20,11][i]?.getD 0
  accumulator := fun i => #[11,11,20,20][i]?.getD 0
theorem rotationDot_2_20_checked : rotationDot_2_20.ExtendedCheck nodes 3 := by decide
def rotationDot_2_21 : DotRecipe where
  left := fun i => #[11,20,11][i]?.getD 0
  right := fun i => #[11,11,19][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_2_21_checked : rotationDot_2_21.ExtendedCheck nodes 3 := by decide
def rotationDot_2_22 : DotRecipe where
  left := fun i => #[11,20,11][i]?.getD 0
  right := fun i => #[11,11,9][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_2_22_checked : rotationDot_2_22.ExtendedCheck nodes 3 := by decide
def rotationDot_2_23 : DotRecipe where
  left := fun i => #[11,20,11][i]?.getD 0
  right := fun i => #[13,12,11][i]?.getD 0
  product := fun i => #[11,2001,11][i]?.getD 0
  accumulator := fun i => #[11,11,2001,2001][i]?.getD 0
theorem rotationDot_2_23_checked : rotationDot_2_23.ExtendedCheck nodes 3 := by decide
def rotationDot_2_24 : DotRecipe where
  left := fun i => #[11,20,11][i]?.getD 0
  right := fun i => #[11,11,1926][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_2_24_checked : rotationDot_2_24.ExtendedCheck nodes 3 := by decide
def rotationDot_2_25 : DotRecipe where
  left := fun i => #[11,20,11][i]?.getD 0
  right := fun i => #[11,11,9][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_2_25_checked : rotationDot_2_25.ExtendedCheck nodes 3 := by decide
def rotationDot_2_26 : DotRecipe where
  left := fun i => #[11,20,11][i]?.getD 0
  right := fun i => #[19,12,11][i]?.getD 0
  product := fun i => #[11,2001,11][i]?.getD 0
  accumulator := fun i => #[11,11,2001,2001][i]?.getD 0
theorem rotationDot_2_26_checked : rotationDot_2_26.ExtendedCheck nodes 3 := by decide
def rotationDotsRow2 : Array DotRecipe := #[rotationDot_2_0,rotationDot_2_1,rotationDot_2_2,rotationDot_2_3,rotationDot_2_4,rotationDot_2_5,rotationDot_2_6,rotationDot_2_7,rotationDot_2_8,rotationDot_2_9,rotationDot_2_10,rotationDot_2_11,rotationDot_2_12,rotationDot_2_13,rotationDot_2_14,rotationDot_2_15,rotationDot_2_16,rotationDot_2_17,rotationDot_2_18,rotationDot_2_19,rotationDot_2_20,rotationDot_2_21,rotationDot_2_22,rotationDot_2_23,rotationDot_2_24,rotationDot_2_25,rotationDot_2_26]
theorem rotationDotsRow2_checked (j : Fin 27) :
    (rotationDotsRow2[j.val]?.getD rotationDot_0_0).ExtendedCheck nodes 3 := by
  fin_cases j
  · exact rotationDot_2_0_checked
  · exact rotationDot_2_1_checked
  · exact rotationDot_2_2_checked
  · exact rotationDot_2_3_checked
  · exact rotationDot_2_4_checked
  · exact rotationDot_2_5_checked
  · exact rotationDot_2_6_checked
  · exact rotationDot_2_7_checked
  · exact rotationDot_2_8_checked
  · exact rotationDot_2_9_checked
  · exact rotationDot_2_10_checked
  · exact rotationDot_2_11_checked
  · exact rotationDot_2_12_checked
  · exact rotationDot_2_13_checked
  · exact rotationDot_2_14_checked
  · exact rotationDot_2_15_checked
  · exact rotationDot_2_16_checked
  · exact rotationDot_2_17_checked
  · exact rotationDot_2_18_checked
  · exact rotationDot_2_19_checked
  · exact rotationDot_2_20_checked
  · exact rotationDot_2_21_checked
  · exact rotationDot_2_22_checked
  · exact rotationDot_2_23_checked
  · exact rotationDot_2_24_checked
  · exact rotationDot_2_25_checked
  · exact rotationDot_2_26_checked
def rotationDot_3_0 : DotRecipe where
  left := fun i => #[11,5,113][i]?.getD 0
  right := fun i => #[11,5,11][i]?.getD 0
  product := fun i => #[11,1927,11][i]?.getD 0
  accumulator := fun i => #[11,11,1927,1927][i]?.getD 0
theorem rotationDot_3_0_checked : rotationDot_3_0.ExtendedCheck nodes 3 := by decide
def rotationDot_3_1 : DotRecipe where
  left := fun i => #[11,5,113][i]?.getD 0
  right := fun i => #[14,11,0][i]?.getD 0
  product := fun i => #[11,11,2004][i]?.getD 0
  accumulator := fun i => #[11,11,11,2004][i]?.getD 0
theorem rotationDot_3_1_checked : rotationDot_3_1.ExtendedCheck nodes 3 := by decide
def rotationDot_3_2 : DotRecipe where
  left := fun i => #[11,5,113][i]?.getD 0
  right := fun i => #[11,20,11][i]?.getD 0
  product := fun i => #[11,1929,11][i]?.getD 0
  accumulator := fun i => #[11,11,1929,1929][i]?.getD 0
theorem rotationDot_3_2_checked : rotationDot_3_2.ExtendedCheck nodes 3 := by decide
def rotationDot_3_3 : DotRecipe where
  left := fun i => #[11,5,113][i]?.getD 0
  right := fun i => #[11,5,113][i]?.getD 0
  product := fun i => #[11,1927,211][i]?.getD 0
  accumulator := fun i => #[11,11,1927,2007][i]?.getD 0
theorem rotationDot_3_3_checked : rotationDot_3_3.ExtendedCheck nodes 3 := by decide
def rotationDot_3_4 : DotRecipe where
  left := fun i => #[11,5,113][i]?.getD 0
  right := fun i => #[14,11,15][i]?.getD 0
  product := fun i => #[11,11,2009][i]?.getD 0
  accumulator := fun i => #[11,11,11,2009][i]?.getD 0
theorem rotationDot_3_4_checked : rotationDot_3_4.ExtendedCheck nodes 3 := by decide
def rotationDot_3_5 : DotRecipe where
  left := fun i => #[11,5,113][i]?.getD 0
  right := fun i => #[16,111,11][i]?.getD 0
  product := fun i => #[11,1932,11][i]?.getD 0
  accumulator := fun i => #[11,11,1932,1932][i]?.getD 0
theorem rotationDot_3_5_checked : rotationDot_3_5.ExtendedCheck nodes 3 := by decide
def rotationDot_3_6 : DotRecipe where
  left := fun i => #[11,5,113][i]?.getD 0
  right := fun i => #[11,5,265][i]?.getD 0
  product := fun i => #[11,1927,2012][i]?.getD 0
  accumulator := fun i => #[11,11,1927,2013][i]?.getD 0
theorem rotationDot_3_6_checked : rotationDot_3_6.ExtendedCheck nodes 3 := by decide
def rotationDot_3_7 : DotRecipe where
  left := fun i => #[11,5,113][i]?.getD 0
  right := fun i => #[14,11,15][i]?.getD 0
  product := fun i => #[11,11,2009][i]?.getD 0
  accumulator := fun i => #[11,11,11,2009][i]?.getD 0
theorem rotationDot_3_7_checked : rotationDot_3_7.ExtendedCheck nodes 3 := by decide
def rotationDot_3_8 : DotRecipe where
  left := fun i => #[11,5,113][i]?.getD 0
  right := fun i => #[17,111,11][i]?.getD 0
  product := fun i => #[11,1932,11][i]?.getD 0
  accumulator := fun i => #[11,11,1932,1932][i]?.getD 0
theorem rotationDot_3_8_checked : rotationDot_3_8.ExtendedCheck nodes 3 := by decide
def rotationDot_3_9 : DotRecipe where
  left := fun i => #[11,5,113][i]?.getD 0
  right := fun i => #[11,14,11][i]?.getD 0
  product := fun i => #[11,1936,11][i]?.getD 0
  accumulator := fun i => #[11,11,1936,1936][i]?.getD 0
theorem rotationDot_3_9_checked : rotationDot_3_9.ExtendedCheck nodes 3 := by decide
def rotationDot_3_10 : DotRecipe where
  left := fun i => #[11,5,113][i]?.getD 0
  right := fun i => #[488,11,0][i]?.getD 0
  product := fun i => #[11,11,2004][i]?.getD 0
  accumulator := fun i => #[11,11,11,2004][i]?.getD 0
theorem rotationDot_3_10_checked : rotationDot_3_10.ExtendedCheck nodes 3 := by decide
def rotationDot_3_11 : DotRecipe where
  left := fun i => #[11,5,113][i]?.getD 0
  right := fun i => #[11,20,11][i]?.getD 0
  product := fun i => #[11,1929,11][i]?.getD 0
  accumulator := fun i => #[11,11,1929,1929][i]?.getD 0
theorem rotationDot_3_11_checked : rotationDot_3_11.ExtendedCheck nodes 3 := by decide
def rotationDot_3_12 : DotRecipe where
  left := fun i => #[11,5,113][i]?.getD 0
  right := fun i => #[11,14,113][i]?.getD 0
  product := fun i => #[11,1936,211][i]?.getD 0
  accumulator := fun i => #[11,11,1936,2020][i]?.getD 0
theorem rotationDot_3_12_checked : rotationDot_3_12.ExtendedCheck nodes 3 := by decide
def rotationDot_3_13 : DotRecipe where
  left := fun i => #[11,5,113][i]?.getD 0
  right := fun i => #[488,11,15][i]?.getD 0
  product := fun i => #[11,11,2009][i]?.getD 0
  accumulator := fun i => #[11,11,11,2009][i]?.getD 0
theorem rotationDot_3_13_checked : rotationDot_3_13.ExtendedCheck nodes 3 := by decide
def rotationDot_3_14 : DotRecipe where
  left := fun i => #[11,5,113][i]?.getD 0
  right := fun i => #[16,111,11][i]?.getD 0
  product := fun i => #[11,1932,11][i]?.getD 0
  accumulator := fun i => #[11,11,1932,1932][i]?.getD 0
theorem rotationDot_3_14_checked : rotationDot_3_14.ExtendedCheck nodes 3 := by decide
def rotationDot_3_15 : DotRecipe where
  left := fun i => #[11,5,113][i]?.getD 0
  right := fun i => #[11,14,265][i]?.getD 0
  product := fun i => #[11,1936,2012][i]?.getD 0
  accumulator := fun i => #[11,11,1936,2024][i]?.getD 0
theorem rotationDot_3_15_checked : rotationDot_3_15.ExtendedCheck nodes 3 := by decide
def rotationDot_3_16 : DotRecipe where
  left := fun i => #[11,5,113][i]?.getD 0
  right := fun i => #[488,11,15][i]?.getD 0
  product := fun i => #[11,11,2009][i]?.getD 0
  accumulator := fun i => #[11,11,11,2009][i]?.getD 0
theorem rotationDot_3_16_checked : rotationDot_3_16.ExtendedCheck nodes 3 := by decide
def rotationDot_3_17 : DotRecipe where
  left := fun i => #[11,5,113][i]?.getD 0
  right := fun i => #[17,111,11][i]?.getD 0
  product := fun i => #[11,1932,11][i]?.getD 0
  accumulator := fun i => #[11,11,1932,1932][i]?.getD 0
theorem rotationDot_3_17_checked : rotationDot_3_17.ExtendedCheck nodes 3 := by decide
def rotationDot_3_18 : DotRecipe where
  left := fun i => #[11,5,113][i]?.getD 0
  right := fun i => #[11,11,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_3_18_checked : rotationDot_3_18.ExtendedCheck nodes 3 := by decide
def rotationDot_3_19 : DotRecipe where
  left := fun i => #[11,5,113][i]?.getD 0
  right := fun i => #[11,11,18][i]?.getD 0
  product := fun i => #[11,11,2028][i]?.getD 0
  accumulator := fun i => #[11,11,11,2028][i]?.getD 0
theorem rotationDot_3_19_checked : rotationDot_3_19.ExtendedCheck nodes 3 := by decide
def rotationDot_3_20 : DotRecipe where
  left := fun i => #[11,5,113][i]?.getD 0
  right := fun i => #[11,2,11][i]?.getD 0
  product := fun i => #[11,5,11][i]?.getD 0
  accumulator := fun i => #[11,11,5,5][i]?.getD 0
theorem rotationDot_3_20_checked : rotationDot_3_20.ExtendedCheck nodes 3 := by decide
def rotationDot_3_21 : DotRecipe where
  left := fun i => #[11,5,113][i]?.getD 0
  right := fun i => #[11,11,19][i]?.getD 0
  product := fun i => #[11,11,2031][i]?.getD 0
  accumulator := fun i => #[11,11,11,2031][i]?.getD 0
theorem rotationDot_3_21_checked : rotationDot_3_21.ExtendedCheck nodes 3 := by decide
def rotationDot_3_22 : DotRecipe where
  left := fun i => #[11,5,113][i]?.getD 0
  right := fun i => #[11,11,9][i]?.getD 0
  product := fun i => #[11,11,2033][i]?.getD 0
  accumulator := fun i => #[11,11,11,2033][i]?.getD 0
theorem rotationDot_3_22_checked : rotationDot_3_22.ExtendedCheck nodes 3 := by decide
def rotationDot_3_23 : DotRecipe where
  left := fun i => #[11,5,113][i]?.getD 0
  right := fun i => #[13,12,11][i]?.getD 0
  product := fun i => #[11,1944,11][i]?.getD 0
  accumulator := fun i => #[11,11,1944,1944][i]?.getD 0
theorem rotationDot_3_23_checked : rotationDot_3_23.ExtendedCheck nodes 3 := by decide
def rotationDot_3_24 : DotRecipe where
  left := fun i => #[11,5,113][i]?.getD 0
  right := fun i => #[11,11,1926][i]?.getD 0
  product := fun i => #[11,11,2036][i]?.getD 0
  accumulator := fun i => #[11,11,11,2036][i]?.getD 0
theorem rotationDot_3_24_checked : rotationDot_3_24.ExtendedCheck nodes 3 := by decide
def rotationDot_3_25 : DotRecipe where
  left := fun i => #[11,5,113][i]?.getD 0
  right := fun i => #[11,11,9][i]?.getD 0
  product := fun i => #[11,11,2033][i]?.getD 0
  accumulator := fun i => #[11,11,11,2033][i]?.getD 0
theorem rotationDot_3_25_checked : rotationDot_3_25.ExtendedCheck nodes 3 := by decide
def rotationDot_3_26 : DotRecipe where
  left := fun i => #[11,5,113][i]?.getD 0
  right := fun i => #[19,12,11][i]?.getD 0
  product := fun i => #[11,1944,11][i]?.getD 0
  accumulator := fun i => #[11,11,1944,1944][i]?.getD 0
theorem rotationDot_3_26_checked : rotationDot_3_26.ExtendedCheck nodes 3 := by decide
def rotationDotsRow3 : Array DotRecipe := #[rotationDot_3_0,rotationDot_3_1,rotationDot_3_2,rotationDot_3_3,rotationDot_3_4,rotationDot_3_5,rotationDot_3_6,rotationDot_3_7,rotationDot_3_8,rotationDot_3_9,rotationDot_3_10,rotationDot_3_11,rotationDot_3_12,rotationDot_3_13,rotationDot_3_14,rotationDot_3_15,rotationDot_3_16,rotationDot_3_17,rotationDot_3_18,rotationDot_3_19,rotationDot_3_20,rotationDot_3_21,rotationDot_3_22,rotationDot_3_23,rotationDot_3_24,rotationDot_3_25,rotationDot_3_26]
theorem rotationDotsRow3_checked (j : Fin 27) :
    (rotationDotsRow3[j.val]?.getD rotationDot_0_0).ExtendedCheck nodes 3 := by
  fin_cases j
  · exact rotationDot_3_0_checked
  · exact rotationDot_3_1_checked
  · exact rotationDot_3_2_checked
  · exact rotationDot_3_3_checked
  · exact rotationDot_3_4_checked
  · exact rotationDot_3_5_checked
  · exact rotationDot_3_6_checked
  · exact rotationDot_3_7_checked
  · exact rotationDot_3_8_checked
  · exact rotationDot_3_9_checked
  · exact rotationDot_3_10_checked
  · exact rotationDot_3_11_checked
  · exact rotationDot_3_12_checked
  · exact rotationDot_3_13_checked
  · exact rotationDot_3_14_checked
  · exact rotationDot_3_15_checked
  · exact rotationDot_3_16_checked
  · exact rotationDot_3_17_checked
  · exact rotationDot_3_18_checked
  · exact rotationDot_3_19_checked
  · exact rotationDot_3_20_checked
  · exact rotationDot_3_21_checked
  · exact rotationDot_3_22_checked
  · exact rotationDot_3_23_checked
  · exact rotationDot_3_24_checked
  · exact rotationDot_3_25_checked
  · exact rotationDot_3_26_checked
def rotationDot_4_0 : DotRecipe where
  left := fun i => #[14,11,15][i]?.getD 0
  right := fun i => #[11,5,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_4_0_checked : rotationDot_4_0.ExtendedCheck nodes 3 := by decide
def rotationDot_4_1 : DotRecipe where
  left := fun i => #[14,11,15][i]?.getD 0
  right := fun i => #[14,11,0][i]?.getD 0
  product := fun i => #[822,11,2040][i]?.getD 0
  accumulator := fun i => #[11,822,822,2041][i]?.getD 0
theorem rotationDot_4_1_checked : rotationDot_4_1.ExtendedCheck nodes 3 := by decide
def rotationDot_4_2 : DotRecipe where
  left := fun i => #[14,11,15][i]?.getD 0
  right := fun i => #[11,20,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_4_2_checked : rotationDot_4_2.ExtendedCheck nodes 3 := by decide
def rotationDot_4_3 : DotRecipe where
  left := fun i => #[14,11,15][i]?.getD 0
  right := fun i => #[11,5,113][i]?.getD 0
  product := fun i => #[11,11,2043][i]?.getD 0
  accumulator := fun i => #[11,11,11,2043][i]?.getD 0
theorem rotationDot_4_3_checked : rotationDot_4_3.ExtendedCheck nodes 3 := by decide
def rotationDot_4_4 : DotRecipe where
  left := fun i => #[14,11,15][i]?.getD 0
  right := fun i => #[14,11,15][i]?.getD 0
  product := fun i => #[822,11,2045][i]?.getD 0
  accumulator := fun i => #[11,822,822,2046][i]?.getD 0
theorem rotationDot_4_4_checked : rotationDot_4_4.ExtendedCheck nodes 3 := by decide
def rotationDot_4_5 : DotRecipe where
  left := fun i => #[14,11,15][i]?.getD 0
  right := fun i => #[16,111,11][i]?.getD 0
  product := fun i => #[1954,11,11][i]?.getD 0
  accumulator := fun i => #[11,1954,1954,1954][i]?.getD 0
theorem rotationDot_4_5_checked : rotationDot_4_5.ExtendedCheck nodes 3 := by decide
def rotationDot_4_6 : DotRecipe where
  left := fun i => #[14,11,15][i]?.getD 0
  right := fun i => #[11,5,265][i]?.getD 0
  product := fun i => #[11,11,2049][i]?.getD 0
  accumulator := fun i => #[11,11,11,2049][i]?.getD 0
theorem rotationDot_4_6_checked : rotationDot_4_6.ExtendedCheck nodes 3 := by decide
def rotationDot_4_7 : DotRecipe where
  left := fun i => #[14,11,15][i]?.getD 0
  right := fun i => #[14,11,15][i]?.getD 0
  product := fun i => #[822,11,2045][i]?.getD 0
  accumulator := fun i => #[11,822,822,2046][i]?.getD 0
theorem rotationDot_4_7_checked : rotationDot_4_7.ExtendedCheck nodes 3 := by decide
def rotationDot_4_8 : DotRecipe where
  left := fun i => #[14,11,15][i]?.getD 0
  right := fun i => #[17,111,11][i]?.getD 0
  product := fun i => #[1959,11,11][i]?.getD 0
  accumulator := fun i => #[11,1959,1959,1959][i]?.getD 0
theorem rotationDot_4_8_checked : rotationDot_4_8.ExtendedCheck nodes 3 := by decide
def rotationDot_4_9 : DotRecipe where
  left := fun i => #[14,11,15][i]?.getD 0
  right := fun i => #[11,14,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_4_9_checked : rotationDot_4_9.ExtendedCheck nodes 3 := by decide
def rotationDot_4_10 : DotRecipe where
  left := fun i => #[14,11,15][i]?.getD 0
  right := fun i => #[488,11,0][i]?.getD 0
  product := fun i => #[1961,11,2040][i]?.getD 0
  accumulator := fun i => #[11,1961,1961,2053][i]?.getD 0
theorem rotationDot_4_10_checked : rotationDot_4_10.ExtendedCheck nodes 3 := by decide
def rotationDot_4_11 : DotRecipe where
  left := fun i => #[14,11,15][i]?.getD 0
  right := fun i => #[11,20,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_4_11_checked : rotationDot_4_11.ExtendedCheck nodes 3 := by decide
def rotationDot_4_12 : DotRecipe where
  left := fun i => #[14,11,15][i]?.getD 0
  right := fun i => #[11,14,113][i]?.getD 0
  product := fun i => #[11,11,2043][i]?.getD 0
  accumulator := fun i => #[11,11,11,2043][i]?.getD 0
theorem rotationDot_4_12_checked : rotationDot_4_12.ExtendedCheck nodes 3 := by decide
def rotationDot_4_13 : DotRecipe where
  left := fun i => #[14,11,15][i]?.getD 0
  right := fun i => #[488,11,15][i]?.getD 0
  product := fun i => #[1961,11,2045][i]?.getD 0
  accumulator := fun i => #[11,1961,1961,2056][i]?.getD 0
theorem rotationDot_4_13_checked : rotationDot_4_13.ExtendedCheck nodes 3 := by decide
def rotationDot_4_14 : DotRecipe where
  left := fun i => #[14,11,15][i]?.getD 0
  right := fun i => #[16,111,11][i]?.getD 0
  product := fun i => #[1954,11,11][i]?.getD 0
  accumulator := fun i => #[11,1954,1954,1954][i]?.getD 0
theorem rotationDot_4_14_checked : rotationDot_4_14.ExtendedCheck nodes 3 := by decide
def rotationDot_4_15 : DotRecipe where
  left := fun i => #[14,11,15][i]?.getD 0
  right := fun i => #[11,14,265][i]?.getD 0
  product := fun i => #[11,11,2049][i]?.getD 0
  accumulator := fun i => #[11,11,11,2049][i]?.getD 0
theorem rotationDot_4_15_checked : rotationDot_4_15.ExtendedCheck nodes 3 := by decide
def rotationDot_4_16 : DotRecipe where
  left := fun i => #[14,11,15][i]?.getD 0
  right := fun i => #[488,11,15][i]?.getD 0
  product := fun i => #[1961,11,2045][i]?.getD 0
  accumulator := fun i => #[11,1961,1961,2056][i]?.getD 0
theorem rotationDot_4_16_checked : rotationDot_4_16.ExtendedCheck nodes 3 := by decide
def rotationDot_4_17 : DotRecipe where
  left := fun i => #[14,11,15][i]?.getD 0
  right := fun i => #[17,111,11][i]?.getD 0
  product := fun i => #[1959,11,11][i]?.getD 0
  accumulator := fun i => #[11,1959,1959,1959][i]?.getD 0
theorem rotationDot_4_17_checked : rotationDot_4_17.ExtendedCheck nodes 3 := by decide
def rotationDot_4_18 : DotRecipe where
  left := fun i => #[14,11,15][i]?.getD 0
  right := fun i => #[11,11,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_4_18_checked : rotationDot_4_18.ExtendedCheck nodes 3 := by decide
def rotationDot_4_19 : DotRecipe where
  left := fun i => #[14,11,15][i]?.getD 0
  right := fun i => #[11,11,18][i]?.getD 0
  product := fun i => #[11,11,2062][i]?.getD 0
  accumulator := fun i => #[11,11,11,2062][i]?.getD 0
theorem rotationDot_4_19_checked : rotationDot_4_19.ExtendedCheck nodes 3 := by decide
def rotationDot_4_20 : DotRecipe where
  left := fun i => #[14,11,15][i]?.getD 0
  right := fun i => #[11,2,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_4_20_checked : rotationDot_4_20.ExtendedCheck nodes 3 := by decide
def rotationDot_4_21 : DotRecipe where
  left := fun i => #[14,11,15][i]?.getD 0
  right := fun i => #[11,11,19][i]?.getD 0
  product := fun i => #[11,11,2064][i]?.getD 0
  accumulator := fun i => #[11,11,11,2064][i]?.getD 0
theorem rotationDot_4_21_checked : rotationDot_4_21.ExtendedCheck nodes 3 := by decide
def rotationDot_4_22 : DotRecipe where
  left := fun i => #[14,11,15][i]?.getD 0
  right := fun i => #[11,11,9][i]?.getD 0
  product := fun i => #[11,11,2066][i]?.getD 0
  accumulator := fun i => #[11,11,11,2066][i]?.getD 0
theorem rotationDot_4_22_checked : rotationDot_4_22.ExtendedCheck nodes 3 := by decide
def rotationDot_4_23 : DotRecipe where
  left := fun i => #[14,11,15][i]?.getD 0
  right := fun i => #[13,12,11][i]?.getD 0
  product := fun i => #[1977,11,11][i]?.getD 0
  accumulator := fun i => #[11,1977,1977,1977][i]?.getD 0
theorem rotationDot_4_23_checked : rotationDot_4_23.ExtendedCheck nodes 3 := by decide
def rotationDot_4_24 : DotRecipe where
  left := fun i => #[14,11,15][i]?.getD 0
  right := fun i => #[11,11,1926][i]?.getD 0
  product := fun i => #[11,11,2069][i]?.getD 0
  accumulator := fun i => #[11,11,11,2069][i]?.getD 0
theorem rotationDot_4_24_checked : rotationDot_4_24.ExtendedCheck nodes 3 := by decide
def rotationDot_4_25 : DotRecipe where
  left := fun i => #[14,11,15][i]?.getD 0
  right := fun i => #[11,11,9][i]?.getD 0
  product := fun i => #[11,11,2066][i]?.getD 0
  accumulator := fun i => #[11,11,11,2066][i]?.getD 0
theorem rotationDot_4_25_checked : rotationDot_4_25.ExtendedCheck nodes 3 := by decide
def rotationDot_4_26 : DotRecipe where
  left := fun i => #[14,11,15][i]?.getD 0
  right := fun i => #[19,12,11][i]?.getD 0
  product := fun i => #[1982,11,11][i]?.getD 0
  accumulator := fun i => #[11,1982,1982,1982][i]?.getD 0
theorem rotationDot_4_26_checked : rotationDot_4_26.ExtendedCheck nodes 3 := by decide
def rotationDotsRow4 : Array DotRecipe := #[rotationDot_4_0,rotationDot_4_1,rotationDot_4_2,rotationDot_4_3,rotationDot_4_4,rotationDot_4_5,rotationDot_4_6,rotationDot_4_7,rotationDot_4_8,rotationDot_4_9,rotationDot_4_10,rotationDot_4_11,rotationDot_4_12,rotationDot_4_13,rotationDot_4_14,rotationDot_4_15,rotationDot_4_16,rotationDot_4_17,rotationDot_4_18,rotationDot_4_19,rotationDot_4_20,rotationDot_4_21,rotationDot_4_22,rotationDot_4_23,rotationDot_4_24,rotationDot_4_25,rotationDot_4_26]
theorem rotationDotsRow4_checked (j : Fin 27) :
    (rotationDotsRow4[j.val]?.getD rotationDot_0_0).ExtendedCheck nodes 3 := by
  fin_cases j
  · exact rotationDot_4_0_checked
  · exact rotationDot_4_1_checked
  · exact rotationDot_4_2_checked
  · exact rotationDot_4_3_checked
  · exact rotationDot_4_4_checked
  · exact rotationDot_4_5_checked
  · exact rotationDot_4_6_checked
  · exact rotationDot_4_7_checked
  · exact rotationDot_4_8_checked
  · exact rotationDot_4_9_checked
  · exact rotationDot_4_10_checked
  · exact rotationDot_4_11_checked
  · exact rotationDot_4_12_checked
  · exact rotationDot_4_13_checked
  · exact rotationDot_4_14_checked
  · exact rotationDot_4_15_checked
  · exact rotationDot_4_16_checked
  · exact rotationDot_4_17_checked
  · exact rotationDot_4_18_checked
  · exact rotationDot_4_19_checked
  · exact rotationDot_4_20_checked
  · exact rotationDot_4_21_checked
  · exact rotationDot_4_22_checked
  · exact rotationDot_4_23_checked
  · exact rotationDot_4_24_checked
  · exact rotationDot_4_25_checked
  · exact rotationDot_4_26_checked
def rotationDot_5_0 : DotRecipe where
  left := fun i => #[16,111,11][i]?.getD 0
  right := fun i => #[11,5,11][i]?.getD 0
  product := fun i => #[11,2073,11][i]?.getD 0
  accumulator := fun i => #[11,11,2073,2073][i]?.getD 0
theorem rotationDot_5_0_checked : rotationDot_5_0.ExtendedCheck nodes 3 := by decide
def rotationDot_5_1 : DotRecipe where
  left := fun i => #[16,111,11][i]?.getD 0
  right := fun i => #[14,11,0][i]?.getD 0
  product := fun i => #[2075,11,11][i]?.getD 0
  accumulator := fun i => #[11,2075,2075,2075][i]?.getD 0
theorem rotationDot_5_1_checked : rotationDot_5_1.ExtendedCheck nodes 3 := by decide
def rotationDot_5_2 : DotRecipe where
  left := fun i => #[16,111,11][i]?.getD 0
  right := fun i => #[11,20,11][i]?.getD 0
  product := fun i => #[11,2077,11][i]?.getD 0
  accumulator := fun i => #[11,11,2077,2077][i]?.getD 0
theorem rotationDot_5_2_checked : rotationDot_5_2.ExtendedCheck nodes 3 := by decide
def rotationDot_5_3 : DotRecipe where
  left := fun i => #[16,111,11][i]?.getD 0
  right := fun i => #[11,5,113][i]?.getD 0
  product := fun i => #[11,2073,11][i]?.getD 0
  accumulator := fun i => #[11,11,2073,2073][i]?.getD 0
theorem rotationDot_5_3_checked : rotationDot_5_3.ExtendedCheck nodes 3 := by decide
def rotationDot_5_4 : DotRecipe where
  left := fun i => #[16,111,11][i]?.getD 0
  right := fun i => #[14,11,15][i]?.getD 0
  product := fun i => #[2075,11,11][i]?.getD 0
  accumulator := fun i => #[11,2075,2075,2075][i]?.getD 0
theorem rotationDot_5_4_checked : rotationDot_5_4.ExtendedCheck nodes 3 := by decide
def rotationDot_5_5 : DotRecipe where
  left := fun i => #[16,111,11][i]?.getD 0
  right := fun i => #[16,111,11][i]?.getD 0
  product := fun i => #[24,2081,11][i]?.getD 0
  accumulator := fun i => #[11,24,2082,2082][i]?.getD 0
theorem rotationDot_5_5_checked : rotationDot_5_5.ExtendedCheck nodes 3 := by decide
def rotationDot_5_6 : DotRecipe where
  left := fun i => #[16,111,11][i]?.getD 0
  right := fun i => #[11,5,265][i]?.getD 0
  product := fun i => #[11,2073,11][i]?.getD 0
  accumulator := fun i => #[11,11,2073,2073][i]?.getD 0
theorem rotationDot_5_6_checked : rotationDot_5_6.ExtendedCheck nodes 3 := by decide
def rotationDot_5_7 : DotRecipe where
  left := fun i => #[16,111,11][i]?.getD 0
  right := fun i => #[14,11,15][i]?.getD 0
  product := fun i => #[2075,11,11][i]?.getD 0
  accumulator := fun i => #[11,2075,2075,2075][i]?.getD 0
theorem rotationDot_5_7_checked : rotationDot_5_7.ExtendedCheck nodes 3 := by decide
def rotationDot_5_8 : DotRecipe where
  left := fun i => #[16,111,11][i]?.getD 0
  right := fun i => #[17,111,11][i]?.getD 0
  product := fun i => #[2086,2081,11][i]?.getD 0
  accumulator := fun i => #[11,2086,2087,2087][i]?.getD 0
theorem rotationDot_5_8_checked : rotationDot_5_8.ExtendedCheck nodes 3 := by decide
def rotationDot_5_9 : DotRecipe where
  left := fun i => #[16,111,11][i]?.getD 0
  right := fun i => #[11,14,11][i]?.getD 0
  product := fun i => #[11,2089,11][i]?.getD 0
  accumulator := fun i => #[11,11,2089,2089][i]?.getD 0
theorem rotationDot_5_9_checked : rotationDot_5_9.ExtendedCheck nodes 3 := by decide
def rotationDot_5_10 : DotRecipe where
  left := fun i => #[16,111,11][i]?.getD 0
  right := fun i => #[488,11,0][i]?.getD 0
  product := fun i => #[2091,11,11][i]?.getD 0
  accumulator := fun i => #[11,2091,2091,2091][i]?.getD 0
theorem rotationDot_5_10_checked : rotationDot_5_10.ExtendedCheck nodes 3 := by decide
def rotationDot_5_11 : DotRecipe where
  left := fun i => #[16,111,11][i]?.getD 0
  right := fun i => #[11,20,11][i]?.getD 0
  product := fun i => #[11,2077,11][i]?.getD 0
  accumulator := fun i => #[11,11,2077,2077][i]?.getD 0
theorem rotationDot_5_11_checked : rotationDot_5_11.ExtendedCheck nodes 3 := by decide
def rotationDot_5_12 : DotRecipe where
  left := fun i => #[16,111,11][i]?.getD 0
  right := fun i => #[11,14,113][i]?.getD 0
  product := fun i => #[11,2089,11][i]?.getD 0
  accumulator := fun i => #[11,11,2089,2089][i]?.getD 0
theorem rotationDot_5_12_checked : rotationDot_5_12.ExtendedCheck nodes 3 := by decide
def rotationDot_5_13 : DotRecipe where
  left := fun i => #[16,111,11][i]?.getD 0
  right := fun i => #[488,11,15][i]?.getD 0
  product := fun i => #[2091,11,11][i]?.getD 0
  accumulator := fun i => #[11,2091,2091,2091][i]?.getD 0
theorem rotationDot_5_13_checked : rotationDot_5_13.ExtendedCheck nodes 3 := by decide
def rotationDot_5_14 : DotRecipe where
  left := fun i => #[16,111,11][i]?.getD 0
  right := fun i => #[16,111,11][i]?.getD 0
  product := fun i => #[24,2081,11][i]?.getD 0
  accumulator := fun i => #[11,24,2082,2082][i]?.getD 0
theorem rotationDot_5_14_checked : rotationDot_5_14.ExtendedCheck nodes 3 := by decide
def rotationDot_5_15 : DotRecipe where
  left := fun i => #[16,111,11][i]?.getD 0
  right := fun i => #[11,14,265][i]?.getD 0
  product := fun i => #[11,2089,11][i]?.getD 0
  accumulator := fun i => #[11,11,2089,2089][i]?.getD 0
theorem rotationDot_5_15_checked : rotationDot_5_15.ExtendedCheck nodes 3 := by decide
def rotationDot_5_16 : DotRecipe where
  left := fun i => #[16,111,11][i]?.getD 0
  right := fun i => #[488,11,15][i]?.getD 0
  product := fun i => #[2091,11,11][i]?.getD 0
  accumulator := fun i => #[11,2091,2091,2091][i]?.getD 0
theorem rotationDot_5_16_checked : rotationDot_5_16.ExtendedCheck nodes 3 := by decide
def rotationDot_5_17 : DotRecipe where
  left := fun i => #[16,111,11][i]?.getD 0
  right := fun i => #[17,111,11][i]?.getD 0
  product := fun i => #[2086,2081,11][i]?.getD 0
  accumulator := fun i => #[11,2086,2087,2087][i]?.getD 0
theorem rotationDot_5_17_checked : rotationDot_5_17.ExtendedCheck nodes 3 := by decide
def rotationDot_5_18 : DotRecipe where
  left := fun i => #[16,111,11][i]?.getD 0
  right := fun i => #[11,11,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_5_18_checked : rotationDot_5_18.ExtendedCheck nodes 3 := by decide
def rotationDot_5_19 : DotRecipe where
  left := fun i => #[16,111,11][i]?.getD 0
  right := fun i => #[11,11,18][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_5_19_checked : rotationDot_5_19.ExtendedCheck nodes 3 := by decide
def rotationDot_5_20 : DotRecipe where
  left := fun i => #[16,111,11][i]?.getD 0
  right := fun i => #[11,2,11][i]?.getD 0
  product := fun i => #[11,111,11][i]?.getD 0
  accumulator := fun i => #[11,11,111,111][i]?.getD 0
theorem rotationDot_5_20_checked : rotationDot_5_20.ExtendedCheck nodes 3 := by decide
def rotationDot_5_21 : DotRecipe where
  left := fun i => #[16,111,11][i]?.getD 0
  right := fun i => #[11,11,19][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_5_21_checked : rotationDot_5_21.ExtendedCheck nodes 3 := by decide
def rotationDot_5_22 : DotRecipe where
  left := fun i => #[16,111,11][i]?.getD 0
  right := fun i => #[11,11,9][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_5_22_checked : rotationDot_5_22.ExtendedCheck nodes 3 := by decide
def rotationDot_5_23 : DotRecipe where
  left := fun i => #[16,111,11][i]?.getD 0
  right := fun i => #[13,12,11][i]?.getD 0
  product := fun i => #[2101,2102,11][i]?.getD 0
  accumulator := fun i => #[11,2101,2103,2103][i]?.getD 0
theorem rotationDot_5_23_checked : rotationDot_5_23.ExtendedCheck nodes 3 := by decide
def rotationDot_5_24 : DotRecipe where
  left := fun i => #[16,111,11][i]?.getD 0
  right := fun i => #[11,11,1926][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_5_24_checked : rotationDot_5_24.ExtendedCheck nodes 3 := by decide
def rotationDot_5_25 : DotRecipe where
  left := fun i => #[16,111,11][i]?.getD 0
  right := fun i => #[11,11,9][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_5_25_checked : rotationDot_5_25.ExtendedCheck nodes 3 := by decide
def rotationDot_5_26 : DotRecipe where
  left := fun i => #[16,111,11][i]?.getD 0
  right := fun i => #[19,12,11][i]?.getD 0
  product := fun i => #[2105,2102,11][i]?.getD 0
  accumulator := fun i => #[11,2105,2106,2106][i]?.getD 0
theorem rotationDot_5_26_checked : rotationDot_5_26.ExtendedCheck nodes 3 := by decide
def rotationDotsRow5 : Array DotRecipe := #[rotationDot_5_0,rotationDot_5_1,rotationDot_5_2,rotationDot_5_3,rotationDot_5_4,rotationDot_5_5,rotationDot_5_6,rotationDot_5_7,rotationDot_5_8,rotationDot_5_9,rotationDot_5_10,rotationDot_5_11,rotationDot_5_12,rotationDot_5_13,rotationDot_5_14,rotationDot_5_15,rotationDot_5_16,rotationDot_5_17,rotationDot_5_18,rotationDot_5_19,rotationDot_5_20,rotationDot_5_21,rotationDot_5_22,rotationDot_5_23,rotationDot_5_24,rotationDot_5_25,rotationDot_5_26]
theorem rotationDotsRow5_checked (j : Fin 27) :
    (rotationDotsRow5[j.val]?.getD rotationDot_0_0).ExtendedCheck nodes 3 := by
  fin_cases j
  · exact rotationDot_5_0_checked
  · exact rotationDot_5_1_checked
  · exact rotationDot_5_2_checked
  · exact rotationDot_5_3_checked
  · exact rotationDot_5_4_checked
  · exact rotationDot_5_5_checked
  · exact rotationDot_5_6_checked
  · exact rotationDot_5_7_checked
  · exact rotationDot_5_8_checked
  · exact rotationDot_5_9_checked
  · exact rotationDot_5_10_checked
  · exact rotationDot_5_11_checked
  · exact rotationDot_5_12_checked
  · exact rotationDot_5_13_checked
  · exact rotationDot_5_14_checked
  · exact rotationDot_5_15_checked
  · exact rotationDot_5_16_checked
  · exact rotationDot_5_17_checked
  · exact rotationDot_5_18_checked
  · exact rotationDot_5_19_checked
  · exact rotationDot_5_20_checked
  · exact rotationDot_5_21_checked
  · exact rotationDot_5_22_checked
  · exact rotationDot_5_23_checked
  · exact rotationDot_5_24_checked
  · exact rotationDot_5_25_checked
  · exact rotationDot_5_26_checked
def rotationDot_6_0 : DotRecipe where
  left := fun i => #[11,5,265][i]?.getD 0
  right := fun i => #[11,5,11][i]?.getD 0
  product := fun i => #[11,1927,11][i]?.getD 0
  accumulator := fun i => #[11,11,1927,1927][i]?.getD 0
theorem rotationDot_6_0_checked : rotationDot_6_0.ExtendedCheck nodes 3 := by decide
def rotationDot_6_1 : DotRecipe where
  left := fun i => #[11,5,265][i]?.getD 0
  right := fun i => #[14,11,0][i]?.getD 0
  product := fun i => #[11,11,2108][i]?.getD 0
  accumulator := fun i => #[11,11,11,2108][i]?.getD 0
theorem rotationDot_6_1_checked : rotationDot_6_1.ExtendedCheck nodes 3 := by decide
def rotationDot_6_2 : DotRecipe where
  left := fun i => #[11,5,265][i]?.getD 0
  right := fun i => #[11,20,11][i]?.getD 0
  product := fun i => #[11,1929,11][i]?.getD 0
  accumulator := fun i => #[11,11,1929,1929][i]?.getD 0
theorem rotationDot_6_2_checked : rotationDot_6_2.ExtendedCheck nodes 3 := by decide
def rotationDot_6_3 : DotRecipe where
  left := fun i => #[11,5,265][i]?.getD 0
  right := fun i => #[11,5,113][i]?.getD 0
  product := fun i => #[11,1927,2111][i]?.getD 0
  accumulator := fun i => #[11,11,1927,2112][i]?.getD 0
theorem rotationDot_6_3_checked : rotationDot_6_3.ExtendedCheck nodes 3 := by decide
def rotationDot_6_4 : DotRecipe where
  left := fun i => #[11,5,265][i]?.getD 0
  right := fun i => #[14,11,15][i]?.getD 0
  product := fun i => #[11,11,2114][i]?.getD 0
  accumulator := fun i => #[11,11,11,2114][i]?.getD 0
theorem rotationDot_6_4_checked : rotationDot_6_4.ExtendedCheck nodes 3 := by decide
def rotationDot_6_5 : DotRecipe where
  left := fun i => #[11,5,265][i]?.getD 0
  right := fun i => #[16,111,11][i]?.getD 0
  product := fun i => #[11,1932,11][i]?.getD 0
  accumulator := fun i => #[11,11,1932,1932][i]?.getD 0
theorem rotationDot_6_5_checked : rotationDot_6_5.ExtendedCheck nodes 3 := by decide
def rotationDot_6_6 : DotRecipe where
  left := fun i => #[11,5,265][i]?.getD 0
  right := fun i => #[11,5,265][i]?.getD 0
  product := fun i => #[11,1927,266][i]?.getD 0
  accumulator := fun i => #[11,11,1927,2116][i]?.getD 0
theorem rotationDot_6_6_checked : rotationDot_6_6.ExtendedCheck nodes 3 := by decide
def rotationDot_6_7 : DotRecipe where
  left := fun i => #[11,5,265][i]?.getD 0
  right := fun i => #[14,11,15][i]?.getD 0
  product := fun i => #[11,11,2114][i]?.getD 0
  accumulator := fun i => #[11,11,11,2114][i]?.getD 0
theorem rotationDot_6_7_checked : rotationDot_6_7.ExtendedCheck nodes 3 := by decide
def rotationDot_6_8 : DotRecipe where
  left := fun i => #[11,5,265][i]?.getD 0
  right := fun i => #[17,111,11][i]?.getD 0
  product := fun i => #[11,1932,11][i]?.getD 0
  accumulator := fun i => #[11,11,1932,1932][i]?.getD 0
theorem rotationDot_6_8_checked : rotationDot_6_8.ExtendedCheck nodes 3 := by decide
def rotationDot_6_9 : DotRecipe where
  left := fun i => #[11,5,265][i]?.getD 0
  right := fun i => #[11,14,11][i]?.getD 0
  product := fun i => #[11,1936,11][i]?.getD 0
  accumulator := fun i => #[11,11,1936,1936][i]?.getD 0
theorem rotationDot_6_9_checked : rotationDot_6_9.ExtendedCheck nodes 3 := by decide
def rotationDot_6_10 : DotRecipe where
  left := fun i => #[11,5,265][i]?.getD 0
  right := fun i => #[488,11,0][i]?.getD 0
  product := fun i => #[11,11,2108][i]?.getD 0
  accumulator := fun i => #[11,11,11,2108][i]?.getD 0
theorem rotationDot_6_10_checked : rotationDot_6_10.ExtendedCheck nodes 3 := by decide
def rotationDot_6_11 : DotRecipe where
  left := fun i => #[11,5,265][i]?.getD 0
  right := fun i => #[11,20,11][i]?.getD 0
  product := fun i => #[11,1929,11][i]?.getD 0
  accumulator := fun i => #[11,11,1929,1929][i]?.getD 0
theorem rotationDot_6_11_checked : rotationDot_6_11.ExtendedCheck nodes 3 := by decide
def rotationDot_6_12 : DotRecipe where
  left := fun i => #[11,5,265][i]?.getD 0
  right := fun i => #[11,14,113][i]?.getD 0
  product := fun i => #[11,1936,2111][i]?.getD 0
  accumulator := fun i => #[11,11,1936,2123][i]?.getD 0
theorem rotationDot_6_12_checked : rotationDot_6_12.ExtendedCheck nodes 3 := by decide
def rotationDot_6_13 : DotRecipe where
  left := fun i => #[11,5,265][i]?.getD 0
  right := fun i => #[488,11,15][i]?.getD 0
  product := fun i => #[11,11,2114][i]?.getD 0
  accumulator := fun i => #[11,11,11,2114][i]?.getD 0
theorem rotationDot_6_13_checked : rotationDot_6_13.ExtendedCheck nodes 3 := by decide
def rotationDot_6_14 : DotRecipe where
  left := fun i => #[11,5,265][i]?.getD 0
  right := fun i => #[16,111,11][i]?.getD 0
  product := fun i => #[11,1932,11][i]?.getD 0
  accumulator := fun i => #[11,11,1932,1932][i]?.getD 0
theorem rotationDot_6_14_checked : rotationDot_6_14.ExtendedCheck nodes 3 := by decide
def rotationDot_6_15 : DotRecipe where
  left := fun i => #[11,5,265][i]?.getD 0
  right := fun i => #[11,14,265][i]?.getD 0
  product := fun i => #[11,1936,266][i]?.getD 0
  accumulator := fun i => #[11,11,1936,2127][i]?.getD 0
theorem rotationDot_6_15_checked : rotationDot_6_15.ExtendedCheck nodes 3 := by decide
def rotationDot_6_16 : DotRecipe where
  left := fun i => #[11,5,265][i]?.getD 0
  right := fun i => #[488,11,15][i]?.getD 0
  product := fun i => #[11,11,2114][i]?.getD 0
  accumulator := fun i => #[11,11,11,2114][i]?.getD 0
theorem rotationDot_6_16_checked : rotationDot_6_16.ExtendedCheck nodes 3 := by decide
def rotationDot_6_17 : DotRecipe where
  left := fun i => #[11,5,265][i]?.getD 0
  right := fun i => #[17,111,11][i]?.getD 0
  product := fun i => #[11,1932,11][i]?.getD 0
  accumulator := fun i => #[11,11,1932,1932][i]?.getD 0
theorem rotationDot_6_17_checked : rotationDot_6_17.ExtendedCheck nodes 3 := by decide
def rotationDot_6_18 : DotRecipe where
  left := fun i => #[11,5,265][i]?.getD 0
  right := fun i => #[11,11,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_6_18_checked : rotationDot_6_18.ExtendedCheck nodes 3 := by decide
def rotationDot_6_19 : DotRecipe where
  left := fun i => #[11,5,265][i]?.getD 0
  right := fun i => #[11,11,18][i]?.getD 0
  product := fun i => #[11,11,2131][i]?.getD 0
  accumulator := fun i => #[11,11,11,2131][i]?.getD 0
theorem rotationDot_6_19_checked : rotationDot_6_19.ExtendedCheck nodes 3 := by decide
def rotationDot_6_20 : DotRecipe where
  left := fun i => #[11,5,265][i]?.getD 0
  right := fun i => #[11,2,11][i]?.getD 0
  product := fun i => #[11,5,11][i]?.getD 0
  accumulator := fun i => #[11,11,5,5][i]?.getD 0
theorem rotationDot_6_20_checked : rotationDot_6_20.ExtendedCheck nodes 3 := by decide
def rotationDot_6_21 : DotRecipe where
  left := fun i => #[11,5,265][i]?.getD 0
  right := fun i => #[11,11,19][i]?.getD 0
  product := fun i => #[11,11,2134][i]?.getD 0
  accumulator := fun i => #[11,11,11,2134][i]?.getD 0
theorem rotationDot_6_21_checked : rotationDot_6_21.ExtendedCheck nodes 3 := by decide
def rotationDot_6_22 : DotRecipe where
  left := fun i => #[11,5,265][i]?.getD 0
  right := fun i => #[11,11,9][i]?.getD 0
  product := fun i => #[11,11,2136][i]?.getD 0
  accumulator := fun i => #[11,11,11,2136][i]?.getD 0
theorem rotationDot_6_22_checked : rotationDot_6_22.ExtendedCheck nodes 3 := by decide
def rotationDot_6_23 : DotRecipe where
  left := fun i => #[11,5,265][i]?.getD 0
  right := fun i => #[13,12,11][i]?.getD 0
  product := fun i => #[11,1944,11][i]?.getD 0
  accumulator := fun i => #[11,11,1944,1944][i]?.getD 0
theorem rotationDot_6_23_checked : rotationDot_6_23.ExtendedCheck nodes 3 := by decide
def rotationDot_6_24 : DotRecipe where
  left := fun i => #[11,5,265][i]?.getD 0
  right := fun i => #[11,11,1926][i]?.getD 0
  product := fun i => #[11,11,2139][i]?.getD 0
  accumulator := fun i => #[11,11,11,2139][i]?.getD 0
theorem rotationDot_6_24_checked : rotationDot_6_24.ExtendedCheck nodes 3 := by decide
def rotationDot_6_25 : DotRecipe where
  left := fun i => #[11,5,265][i]?.getD 0
  right := fun i => #[11,11,9][i]?.getD 0
  product := fun i => #[11,11,2136][i]?.getD 0
  accumulator := fun i => #[11,11,11,2136][i]?.getD 0
theorem rotationDot_6_25_checked : rotationDot_6_25.ExtendedCheck nodes 3 := by decide
def rotationDot_6_26 : DotRecipe where
  left := fun i => #[11,5,265][i]?.getD 0
  right := fun i => #[19,12,11][i]?.getD 0
  product := fun i => #[11,1944,11][i]?.getD 0
  accumulator := fun i => #[11,11,1944,1944][i]?.getD 0
theorem rotationDot_6_26_checked : rotationDot_6_26.ExtendedCheck nodes 3 := by decide
def rotationDotsRow6 : Array DotRecipe := #[rotationDot_6_0,rotationDot_6_1,rotationDot_6_2,rotationDot_6_3,rotationDot_6_4,rotationDot_6_5,rotationDot_6_6,rotationDot_6_7,rotationDot_6_8,rotationDot_6_9,rotationDot_6_10,rotationDot_6_11,rotationDot_6_12,rotationDot_6_13,rotationDot_6_14,rotationDot_6_15,rotationDot_6_16,rotationDot_6_17,rotationDot_6_18,rotationDot_6_19,rotationDot_6_20,rotationDot_6_21,rotationDot_6_22,rotationDot_6_23,rotationDot_6_24,rotationDot_6_25,rotationDot_6_26]
theorem rotationDotsRow6_checked (j : Fin 27) :
    (rotationDotsRow6[j.val]?.getD rotationDot_0_0).ExtendedCheck nodes 3 := by
  fin_cases j
  · exact rotationDot_6_0_checked
  · exact rotationDot_6_1_checked
  · exact rotationDot_6_2_checked
  · exact rotationDot_6_3_checked
  · exact rotationDot_6_4_checked
  · exact rotationDot_6_5_checked
  · exact rotationDot_6_6_checked
  · exact rotationDot_6_7_checked
  · exact rotationDot_6_8_checked
  · exact rotationDot_6_9_checked
  · exact rotationDot_6_10_checked
  · exact rotationDot_6_11_checked
  · exact rotationDot_6_12_checked
  · exact rotationDot_6_13_checked
  · exact rotationDot_6_14_checked
  · exact rotationDot_6_15_checked
  · exact rotationDot_6_16_checked
  · exact rotationDot_6_17_checked
  · exact rotationDot_6_18_checked
  · exact rotationDot_6_19_checked
  · exact rotationDot_6_20_checked
  · exact rotationDot_6_21_checked
  · exact rotationDot_6_22_checked
  · exact rotationDot_6_23_checked
  · exact rotationDot_6_24_checked
  · exact rotationDot_6_25_checked
  · exact rotationDot_6_26_checked
def rotationDot_7_0 : DotRecipe where
  left := fun i => #[14,11,15][i]?.getD 0
  right := fun i => #[11,5,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_7_0_checked : rotationDot_7_0.ExtendedCheck nodes 3 := by decide
def rotationDot_7_1 : DotRecipe where
  left := fun i => #[14,11,15][i]?.getD 0
  right := fun i => #[14,11,0][i]?.getD 0
  product := fun i => #[822,11,2040][i]?.getD 0
  accumulator := fun i => #[11,822,822,2041][i]?.getD 0
theorem rotationDot_7_1_checked : rotationDot_7_1.ExtendedCheck nodes 3 := by decide
def rotationDot_7_2 : DotRecipe where
  left := fun i => #[14,11,15][i]?.getD 0
  right := fun i => #[11,20,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_7_2_checked : rotationDot_7_2.ExtendedCheck nodes 3 := by decide
def rotationDot_7_3 : DotRecipe where
  left := fun i => #[14,11,15][i]?.getD 0
  right := fun i => #[11,5,113][i]?.getD 0
  product := fun i => #[11,11,2043][i]?.getD 0
  accumulator := fun i => #[11,11,11,2043][i]?.getD 0
theorem rotationDot_7_3_checked : rotationDot_7_3.ExtendedCheck nodes 3 := by decide
def rotationDot_7_4 : DotRecipe where
  left := fun i => #[14,11,15][i]?.getD 0
  right := fun i => #[14,11,15][i]?.getD 0
  product := fun i => #[822,11,2045][i]?.getD 0
  accumulator := fun i => #[11,822,822,2046][i]?.getD 0
theorem rotationDot_7_4_checked : rotationDot_7_4.ExtendedCheck nodes 3 := by decide
def rotationDot_7_5 : DotRecipe where
  left := fun i => #[14,11,15][i]?.getD 0
  right := fun i => #[16,111,11][i]?.getD 0
  product := fun i => #[1954,11,11][i]?.getD 0
  accumulator := fun i => #[11,1954,1954,1954][i]?.getD 0
theorem rotationDot_7_5_checked : rotationDot_7_5.ExtendedCheck nodes 3 := by decide
def rotationDot_7_6 : DotRecipe where
  left := fun i => #[14,11,15][i]?.getD 0
  right := fun i => #[11,5,265][i]?.getD 0
  product := fun i => #[11,11,2049][i]?.getD 0
  accumulator := fun i => #[11,11,11,2049][i]?.getD 0
theorem rotationDot_7_6_checked : rotationDot_7_6.ExtendedCheck nodes 3 := by decide
def rotationDot_7_7 : DotRecipe where
  left := fun i => #[14,11,15][i]?.getD 0
  right := fun i => #[14,11,15][i]?.getD 0
  product := fun i => #[822,11,2045][i]?.getD 0
  accumulator := fun i => #[11,822,822,2046][i]?.getD 0
theorem rotationDot_7_7_checked : rotationDot_7_7.ExtendedCheck nodes 3 := by decide
def rotationDot_7_8 : DotRecipe where
  left := fun i => #[14,11,15][i]?.getD 0
  right := fun i => #[17,111,11][i]?.getD 0
  product := fun i => #[1959,11,11][i]?.getD 0
  accumulator := fun i => #[11,1959,1959,1959][i]?.getD 0
theorem rotationDot_7_8_checked : rotationDot_7_8.ExtendedCheck nodes 3 := by decide
def rotationDot_7_9 : DotRecipe where
  left := fun i => #[14,11,15][i]?.getD 0
  right := fun i => #[11,14,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_7_9_checked : rotationDot_7_9.ExtendedCheck nodes 3 := by decide
def rotationDot_7_10 : DotRecipe where
  left := fun i => #[14,11,15][i]?.getD 0
  right := fun i => #[488,11,0][i]?.getD 0
  product := fun i => #[1961,11,2040][i]?.getD 0
  accumulator := fun i => #[11,1961,1961,2053][i]?.getD 0
theorem rotationDot_7_10_checked : rotationDot_7_10.ExtendedCheck nodes 3 := by decide
def rotationDot_7_11 : DotRecipe where
  left := fun i => #[14,11,15][i]?.getD 0
  right := fun i => #[11,20,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_7_11_checked : rotationDot_7_11.ExtendedCheck nodes 3 := by decide
def rotationDot_7_12 : DotRecipe where
  left := fun i => #[14,11,15][i]?.getD 0
  right := fun i => #[11,14,113][i]?.getD 0
  product := fun i => #[11,11,2043][i]?.getD 0
  accumulator := fun i => #[11,11,11,2043][i]?.getD 0
theorem rotationDot_7_12_checked : rotationDot_7_12.ExtendedCheck nodes 3 := by decide
def rotationDot_7_13 : DotRecipe where
  left := fun i => #[14,11,15][i]?.getD 0
  right := fun i => #[488,11,15][i]?.getD 0
  product := fun i => #[1961,11,2045][i]?.getD 0
  accumulator := fun i => #[11,1961,1961,2056][i]?.getD 0
theorem rotationDot_7_13_checked : rotationDot_7_13.ExtendedCheck nodes 3 := by decide
def rotationDot_7_14 : DotRecipe where
  left := fun i => #[14,11,15][i]?.getD 0
  right := fun i => #[16,111,11][i]?.getD 0
  product := fun i => #[1954,11,11][i]?.getD 0
  accumulator := fun i => #[11,1954,1954,1954][i]?.getD 0
theorem rotationDot_7_14_checked : rotationDot_7_14.ExtendedCheck nodes 3 := by decide
def rotationDot_7_15 : DotRecipe where
  left := fun i => #[14,11,15][i]?.getD 0
  right := fun i => #[11,14,265][i]?.getD 0
  product := fun i => #[11,11,2049][i]?.getD 0
  accumulator := fun i => #[11,11,11,2049][i]?.getD 0
theorem rotationDot_7_15_checked : rotationDot_7_15.ExtendedCheck nodes 3 := by decide
def rotationDot_7_16 : DotRecipe where
  left := fun i => #[14,11,15][i]?.getD 0
  right := fun i => #[488,11,15][i]?.getD 0
  product := fun i => #[1961,11,2045][i]?.getD 0
  accumulator := fun i => #[11,1961,1961,2056][i]?.getD 0
theorem rotationDot_7_16_checked : rotationDot_7_16.ExtendedCheck nodes 3 := by decide
def rotationDot_7_17 : DotRecipe where
  left := fun i => #[14,11,15][i]?.getD 0
  right := fun i => #[17,111,11][i]?.getD 0
  product := fun i => #[1959,11,11][i]?.getD 0
  accumulator := fun i => #[11,1959,1959,1959][i]?.getD 0
theorem rotationDot_7_17_checked : rotationDot_7_17.ExtendedCheck nodes 3 := by decide
def rotationDot_7_18 : DotRecipe where
  left := fun i => #[14,11,15][i]?.getD 0
  right := fun i => #[11,11,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_7_18_checked : rotationDot_7_18.ExtendedCheck nodes 3 := by decide
def rotationDot_7_19 : DotRecipe where
  left := fun i => #[14,11,15][i]?.getD 0
  right := fun i => #[11,11,18][i]?.getD 0
  product := fun i => #[11,11,2062][i]?.getD 0
  accumulator := fun i => #[11,11,11,2062][i]?.getD 0
theorem rotationDot_7_19_checked : rotationDot_7_19.ExtendedCheck nodes 3 := by decide
def rotationDot_7_20 : DotRecipe where
  left := fun i => #[14,11,15][i]?.getD 0
  right := fun i => #[11,2,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_7_20_checked : rotationDot_7_20.ExtendedCheck nodes 3 := by decide
def rotationDot_7_21 : DotRecipe where
  left := fun i => #[14,11,15][i]?.getD 0
  right := fun i => #[11,11,19][i]?.getD 0
  product := fun i => #[11,11,2064][i]?.getD 0
  accumulator := fun i => #[11,11,11,2064][i]?.getD 0
theorem rotationDot_7_21_checked : rotationDot_7_21.ExtendedCheck nodes 3 := by decide
def rotationDot_7_22 : DotRecipe where
  left := fun i => #[14,11,15][i]?.getD 0
  right := fun i => #[11,11,9][i]?.getD 0
  product := fun i => #[11,11,2066][i]?.getD 0
  accumulator := fun i => #[11,11,11,2066][i]?.getD 0
theorem rotationDot_7_22_checked : rotationDot_7_22.ExtendedCheck nodes 3 := by decide
def rotationDot_7_23 : DotRecipe where
  left := fun i => #[14,11,15][i]?.getD 0
  right := fun i => #[13,12,11][i]?.getD 0
  product := fun i => #[1977,11,11][i]?.getD 0
  accumulator := fun i => #[11,1977,1977,1977][i]?.getD 0
theorem rotationDot_7_23_checked : rotationDot_7_23.ExtendedCheck nodes 3 := by decide
def rotationDot_7_24 : DotRecipe where
  left := fun i => #[14,11,15][i]?.getD 0
  right := fun i => #[11,11,1926][i]?.getD 0
  product := fun i => #[11,11,2069][i]?.getD 0
  accumulator := fun i => #[11,11,11,2069][i]?.getD 0
theorem rotationDot_7_24_checked : rotationDot_7_24.ExtendedCheck nodes 3 := by decide
def rotationDot_7_25 : DotRecipe where
  left := fun i => #[14,11,15][i]?.getD 0
  right := fun i => #[11,11,9][i]?.getD 0
  product := fun i => #[11,11,2066][i]?.getD 0
  accumulator := fun i => #[11,11,11,2066][i]?.getD 0
theorem rotationDot_7_25_checked : rotationDot_7_25.ExtendedCheck nodes 3 := by decide
def rotationDot_7_26 : DotRecipe where
  left := fun i => #[14,11,15][i]?.getD 0
  right := fun i => #[19,12,11][i]?.getD 0
  product := fun i => #[1982,11,11][i]?.getD 0
  accumulator := fun i => #[11,1982,1982,1982][i]?.getD 0
theorem rotationDot_7_26_checked : rotationDot_7_26.ExtendedCheck nodes 3 := by decide
def rotationDotsRow7 : Array DotRecipe := #[rotationDot_7_0,rotationDot_7_1,rotationDot_7_2,rotationDot_7_3,rotationDot_7_4,rotationDot_7_5,rotationDot_7_6,rotationDot_7_7,rotationDot_7_8,rotationDot_7_9,rotationDot_7_10,rotationDot_7_11,rotationDot_7_12,rotationDot_7_13,rotationDot_7_14,rotationDot_7_15,rotationDot_7_16,rotationDot_7_17,rotationDot_7_18,rotationDot_7_19,rotationDot_7_20,rotationDot_7_21,rotationDot_7_22,rotationDot_7_23,rotationDot_7_24,rotationDot_7_25,rotationDot_7_26]
theorem rotationDotsRow7_checked (j : Fin 27) :
    (rotationDotsRow7[j.val]?.getD rotationDot_0_0).ExtendedCheck nodes 3 := by
  fin_cases j
  · exact rotationDot_7_0_checked
  · exact rotationDot_7_1_checked
  · exact rotationDot_7_2_checked
  · exact rotationDot_7_3_checked
  · exact rotationDot_7_4_checked
  · exact rotationDot_7_5_checked
  · exact rotationDot_7_6_checked
  · exact rotationDot_7_7_checked
  · exact rotationDot_7_8_checked
  · exact rotationDot_7_9_checked
  · exact rotationDot_7_10_checked
  · exact rotationDot_7_11_checked
  · exact rotationDot_7_12_checked
  · exact rotationDot_7_13_checked
  · exact rotationDot_7_14_checked
  · exact rotationDot_7_15_checked
  · exact rotationDot_7_16_checked
  · exact rotationDot_7_17_checked
  · exact rotationDot_7_18_checked
  · exact rotationDot_7_19_checked
  · exact rotationDot_7_20_checked
  · exact rotationDot_7_21_checked
  · exact rotationDot_7_22_checked
  · exact rotationDot_7_23_checked
  · exact rotationDot_7_24_checked
  · exact rotationDot_7_25_checked
  · exact rotationDot_7_26_checked
def rotationDot_8_0 : DotRecipe where
  left := fun i => #[17,111,11][i]?.getD 0
  right := fun i => #[11,5,11][i]?.getD 0
  product := fun i => #[11,2073,11][i]?.getD 0
  accumulator := fun i => #[11,11,2073,2073][i]?.getD 0
theorem rotationDot_8_0_checked : rotationDot_8_0.ExtendedCheck nodes 3 := by decide
def rotationDot_8_1 : DotRecipe where
  left := fun i => #[17,111,11][i]?.getD 0
  right := fun i => #[14,11,0][i]?.getD 0
  product := fun i => #[2164,11,11][i]?.getD 0
  accumulator := fun i => #[11,2164,2164,2164][i]?.getD 0
theorem rotationDot_8_1_checked : rotationDot_8_1.ExtendedCheck nodes 3 := by decide
def rotationDot_8_2 : DotRecipe where
  left := fun i => #[17,111,11][i]?.getD 0
  right := fun i => #[11,20,11][i]?.getD 0
  product := fun i => #[11,2077,11][i]?.getD 0
  accumulator := fun i => #[11,11,2077,2077][i]?.getD 0
theorem rotationDot_8_2_checked : rotationDot_8_2.ExtendedCheck nodes 3 := by decide
def rotationDot_8_3 : DotRecipe where
  left := fun i => #[17,111,11][i]?.getD 0
  right := fun i => #[11,5,113][i]?.getD 0
  product := fun i => #[11,2073,11][i]?.getD 0
  accumulator := fun i => #[11,11,2073,2073][i]?.getD 0
theorem rotationDot_8_3_checked : rotationDot_8_3.ExtendedCheck nodes 3 := by decide
def rotationDot_8_4 : DotRecipe where
  left := fun i => #[17,111,11][i]?.getD 0
  right := fun i => #[14,11,15][i]?.getD 0
  product := fun i => #[2164,11,11][i]?.getD 0
  accumulator := fun i => #[11,2164,2164,2164][i]?.getD 0
theorem rotationDot_8_4_checked : rotationDot_8_4.ExtendedCheck nodes 3 := by decide
def rotationDot_8_5 : DotRecipe where
  left := fun i => #[17,111,11][i]?.getD 0
  right := fun i => #[16,111,11][i]?.getD 0
  product := fun i => #[2168,2081,11][i]?.getD 0
  accumulator := fun i => #[11,2168,2169,2169][i]?.getD 0
theorem rotationDot_8_5_checked : rotationDot_8_5.ExtendedCheck nodes 3 := by decide
def rotationDot_8_6 : DotRecipe where
  left := fun i => #[17,111,11][i]?.getD 0
  right := fun i => #[11,5,265][i]?.getD 0
  product := fun i => #[11,2073,11][i]?.getD 0
  accumulator := fun i => #[11,11,2073,2073][i]?.getD 0
theorem rotationDot_8_6_checked : rotationDot_8_6.ExtendedCheck nodes 3 := by decide
def rotationDot_8_7 : DotRecipe where
  left := fun i => #[17,111,11][i]?.getD 0
  right := fun i => #[14,11,15][i]?.getD 0
  product := fun i => #[2164,11,11][i]?.getD 0
  accumulator := fun i => #[11,2164,2164,2164][i]?.getD 0
theorem rotationDot_8_7_checked : rotationDot_8_7.ExtendedCheck nodes 3 := by decide
def rotationDot_8_8 : DotRecipe where
  left := fun i => #[17,111,11][i]?.getD 0
  right := fun i => #[17,111,11][i]?.getD 0
  product := fun i => #[63,2081,11][i]?.getD 0
  accumulator := fun i => #[11,63,2173,2173][i]?.getD 0
theorem rotationDot_8_8_checked : rotationDot_8_8.ExtendedCheck nodes 3 := by decide
def rotationDot_8_9 : DotRecipe where
  left := fun i => #[17,111,11][i]?.getD 0
  right := fun i => #[11,14,11][i]?.getD 0
  product := fun i => #[11,2089,11][i]?.getD 0
  accumulator := fun i => #[11,11,2089,2089][i]?.getD 0
theorem rotationDot_8_9_checked : rotationDot_8_9.ExtendedCheck nodes 3 := by decide
def rotationDot_8_10 : DotRecipe where
  left := fun i => #[17,111,11][i]?.getD 0
  right := fun i => #[488,11,0][i]?.getD 0
  product := fun i => #[2176,11,11][i]?.getD 0
  accumulator := fun i => #[11,2176,2176,2176][i]?.getD 0
theorem rotationDot_8_10_checked : rotationDot_8_10.ExtendedCheck nodes 3 := by decide
def rotationDot_8_11 : DotRecipe where
  left := fun i => #[17,111,11][i]?.getD 0
  right := fun i => #[11,20,11][i]?.getD 0
  product := fun i => #[11,2077,11][i]?.getD 0
  accumulator := fun i => #[11,11,2077,2077][i]?.getD 0
theorem rotationDot_8_11_checked : rotationDot_8_11.ExtendedCheck nodes 3 := by decide
def rotationDot_8_12 : DotRecipe where
  left := fun i => #[17,111,11][i]?.getD 0
  right := fun i => #[11,14,113][i]?.getD 0
  product := fun i => #[11,2089,11][i]?.getD 0
  accumulator := fun i => #[11,11,2089,2089][i]?.getD 0
theorem rotationDot_8_12_checked : rotationDot_8_12.ExtendedCheck nodes 3 := by decide
def rotationDot_8_13 : DotRecipe where
  left := fun i => #[17,111,11][i]?.getD 0
  right := fun i => #[488,11,15][i]?.getD 0
  product := fun i => #[2176,11,11][i]?.getD 0
  accumulator := fun i => #[11,2176,2176,2176][i]?.getD 0
theorem rotationDot_8_13_checked : rotationDot_8_13.ExtendedCheck nodes 3 := by decide
def rotationDot_8_14 : DotRecipe where
  left := fun i => #[17,111,11][i]?.getD 0
  right := fun i => #[16,111,11][i]?.getD 0
  product := fun i => #[2168,2081,11][i]?.getD 0
  accumulator := fun i => #[11,2168,2169,2169][i]?.getD 0
theorem rotationDot_8_14_checked : rotationDot_8_14.ExtendedCheck nodes 3 := by decide
def rotationDot_8_15 : DotRecipe where
  left := fun i => #[17,111,11][i]?.getD 0
  right := fun i => #[11,14,265][i]?.getD 0
  product := fun i => #[11,2089,11][i]?.getD 0
  accumulator := fun i => #[11,11,2089,2089][i]?.getD 0
theorem rotationDot_8_15_checked : rotationDot_8_15.ExtendedCheck nodes 3 := by decide
def rotationDot_8_16 : DotRecipe where
  left := fun i => #[17,111,11][i]?.getD 0
  right := fun i => #[488,11,15][i]?.getD 0
  product := fun i => #[2176,11,11][i]?.getD 0
  accumulator := fun i => #[11,2176,2176,2176][i]?.getD 0
theorem rotationDot_8_16_checked : rotationDot_8_16.ExtendedCheck nodes 3 := by decide
def rotationDot_8_17 : DotRecipe where
  left := fun i => #[17,111,11][i]?.getD 0
  right := fun i => #[17,111,11][i]?.getD 0
  product := fun i => #[63,2081,11][i]?.getD 0
  accumulator := fun i => #[11,63,2173,2173][i]?.getD 0
theorem rotationDot_8_17_checked : rotationDot_8_17.ExtendedCheck nodes 3 := by decide
def rotationDot_8_18 : DotRecipe where
  left := fun i => #[17,111,11][i]?.getD 0
  right := fun i => #[11,11,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_8_18_checked : rotationDot_8_18.ExtendedCheck nodes 3 := by decide
def rotationDot_8_19 : DotRecipe where
  left := fun i => #[17,111,11][i]?.getD 0
  right := fun i => #[11,11,18][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_8_19_checked : rotationDot_8_19.ExtendedCheck nodes 3 := by decide
def rotationDot_8_20 : DotRecipe where
  left := fun i => #[17,111,11][i]?.getD 0
  right := fun i => #[11,2,11][i]?.getD 0
  product := fun i => #[11,111,11][i]?.getD 0
  accumulator := fun i => #[11,11,111,111][i]?.getD 0
theorem rotationDot_8_20_checked : rotationDot_8_20.ExtendedCheck nodes 3 := by decide
def rotationDot_8_21 : DotRecipe where
  left := fun i => #[17,111,11][i]?.getD 0
  right := fun i => #[11,11,19][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_8_21_checked : rotationDot_8_21.ExtendedCheck nodes 3 := by decide
def rotationDot_8_22 : DotRecipe where
  left := fun i => #[17,111,11][i]?.getD 0
  right := fun i => #[11,11,9][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_8_22_checked : rotationDot_8_22.ExtendedCheck nodes 3 := by decide
def rotationDot_8_23 : DotRecipe where
  left := fun i => #[17,111,11][i]?.getD 0
  right := fun i => #[13,12,11][i]?.getD 0
  product := fun i => #[2186,2102,11][i]?.getD 0
  accumulator := fun i => #[11,2186,2187,2187][i]?.getD 0
theorem rotationDot_8_23_checked : rotationDot_8_23.ExtendedCheck nodes 3 := by decide
def rotationDot_8_24 : DotRecipe where
  left := fun i => #[17,111,11][i]?.getD 0
  right := fun i => #[11,11,1926][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_8_24_checked : rotationDot_8_24.ExtendedCheck nodes 3 := by decide
def rotationDot_8_25 : DotRecipe where
  left := fun i => #[17,111,11][i]?.getD 0
  right := fun i => #[11,11,9][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_8_25_checked : rotationDot_8_25.ExtendedCheck nodes 3 := by decide
def rotationDot_8_26 : DotRecipe where
  left := fun i => #[17,111,11][i]?.getD 0
  right := fun i => #[19,12,11][i]?.getD 0
  product := fun i => #[2189,2102,11][i]?.getD 0
  accumulator := fun i => #[11,2189,2190,2190][i]?.getD 0
theorem rotationDot_8_26_checked : rotationDot_8_26.ExtendedCheck nodes 3 := by decide
def rotationDotsRow8 : Array DotRecipe := #[rotationDot_8_0,rotationDot_8_1,rotationDot_8_2,rotationDot_8_3,rotationDot_8_4,rotationDot_8_5,rotationDot_8_6,rotationDot_8_7,rotationDot_8_8,rotationDot_8_9,rotationDot_8_10,rotationDot_8_11,rotationDot_8_12,rotationDot_8_13,rotationDot_8_14,rotationDot_8_15,rotationDot_8_16,rotationDot_8_17,rotationDot_8_18,rotationDot_8_19,rotationDot_8_20,rotationDot_8_21,rotationDot_8_22,rotationDot_8_23,rotationDot_8_24,rotationDot_8_25,rotationDot_8_26]
theorem rotationDotsRow8_checked (j : Fin 27) :
    (rotationDotsRow8[j.val]?.getD rotationDot_0_0).ExtendedCheck nodes 3 := by
  fin_cases j
  · exact rotationDot_8_0_checked
  · exact rotationDot_8_1_checked
  · exact rotationDot_8_2_checked
  · exact rotationDot_8_3_checked
  · exact rotationDot_8_4_checked
  · exact rotationDot_8_5_checked
  · exact rotationDot_8_6_checked
  · exact rotationDot_8_7_checked
  · exact rotationDot_8_8_checked
  · exact rotationDot_8_9_checked
  · exact rotationDot_8_10_checked
  · exact rotationDot_8_11_checked
  · exact rotationDot_8_12_checked
  · exact rotationDot_8_13_checked
  · exact rotationDot_8_14_checked
  · exact rotationDot_8_15_checked
  · exact rotationDot_8_16_checked
  · exact rotationDot_8_17_checked
  · exact rotationDot_8_18_checked
  · exact rotationDot_8_19_checked
  · exact rotationDot_8_20_checked
  · exact rotationDot_8_21_checked
  · exact rotationDot_8_22_checked
  · exact rotationDot_8_23_checked
  · exact rotationDot_8_24_checked
  · exact rotationDot_8_25_checked
  · exact rotationDot_8_26_checked
def rotationDot_9_0 : DotRecipe where
  left := fun i => #[11,14,11][i]?.getD 0
  right := fun i => #[11,5,11][i]?.getD 0
  product := fun i => #[11,2192,11][i]?.getD 0
  accumulator := fun i => #[11,11,2192,2192][i]?.getD 0
theorem rotationDot_9_0_checked : rotationDot_9_0.ExtendedCheck nodes 3 := by decide
def rotationDot_9_1 : DotRecipe where
  left := fun i => #[11,14,11][i]?.getD 0
  right := fun i => #[14,11,0][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_9_1_checked : rotationDot_9_1.ExtendedCheck nodes 3 := by decide
def rotationDot_9_2 : DotRecipe where
  left := fun i => #[11,14,11][i]?.getD 0
  right := fun i => #[11,20,11][i]?.getD 0
  product := fun i => #[11,2194,11][i]?.getD 0
  accumulator := fun i => #[11,11,2194,2194][i]?.getD 0
theorem rotationDot_9_2_checked : rotationDot_9_2.ExtendedCheck nodes 3 := by decide
def rotationDot_9_3 : DotRecipe where
  left := fun i => #[11,14,11][i]?.getD 0
  right := fun i => #[11,5,113][i]?.getD 0
  product := fun i => #[11,2192,11][i]?.getD 0
  accumulator := fun i => #[11,11,2192,2192][i]?.getD 0
theorem rotationDot_9_3_checked : rotationDot_9_3.ExtendedCheck nodes 3 := by decide
def rotationDot_9_4 : DotRecipe where
  left := fun i => #[11,14,11][i]?.getD 0
  right := fun i => #[14,11,15][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_9_4_checked : rotationDot_9_4.ExtendedCheck nodes 3 := by decide
def rotationDot_9_5 : DotRecipe where
  left := fun i => #[11,14,11][i]?.getD 0
  right := fun i => #[16,111,11][i]?.getD 0
  product := fun i => #[11,2197,11][i]?.getD 0
  accumulator := fun i => #[11,11,2197,2197][i]?.getD 0
theorem rotationDot_9_5_checked : rotationDot_9_5.ExtendedCheck nodes 3 := by decide
def rotationDot_9_6 : DotRecipe where
  left := fun i => #[11,14,11][i]?.getD 0
  right := fun i => #[11,5,265][i]?.getD 0
  product := fun i => #[11,2192,11][i]?.getD 0
  accumulator := fun i => #[11,11,2192,2192][i]?.getD 0
theorem rotationDot_9_6_checked : rotationDot_9_6.ExtendedCheck nodes 3 := by decide
def rotationDot_9_7 : DotRecipe where
  left := fun i => #[11,14,11][i]?.getD 0
  right := fun i => #[14,11,15][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_9_7_checked : rotationDot_9_7.ExtendedCheck nodes 3 := by decide
def rotationDot_9_8 : DotRecipe where
  left := fun i => #[11,14,11][i]?.getD 0
  right := fun i => #[17,111,11][i]?.getD 0
  product := fun i => #[11,2197,11][i]?.getD 0
  accumulator := fun i => #[11,11,2197,2197][i]?.getD 0
theorem rotationDot_9_8_checked : rotationDot_9_8.ExtendedCheck nodes 3 := by decide
def rotationDot_9_9 : DotRecipe where
  left := fun i => #[11,14,11][i]?.getD 0
  right := fun i => #[11,14,11][i]?.getD 0
  product := fun i => #[11,822,11][i]?.getD 0
  accumulator := fun i => #[11,11,822,822][i]?.getD 0
theorem rotationDot_9_9_checked : rotationDot_9_9.ExtendedCheck nodes 3 := by decide
def rotationDot_9_10 : DotRecipe where
  left := fun i => #[11,14,11][i]?.getD 0
  right := fun i => #[488,11,0][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_9_10_checked : rotationDot_9_10.ExtendedCheck nodes 3 := by decide
def rotationDot_9_11 : DotRecipe where
  left := fun i => #[11,14,11][i]?.getD 0
  right := fun i => #[11,20,11][i]?.getD 0
  product := fun i => #[11,2194,11][i]?.getD 0
  accumulator := fun i => #[11,11,2194,2194][i]?.getD 0
theorem rotationDot_9_11_checked : rotationDot_9_11.ExtendedCheck nodes 3 := by decide
def rotationDot_9_12 : DotRecipe where
  left := fun i => #[11,14,11][i]?.getD 0
  right := fun i => #[11,14,113][i]?.getD 0
  product := fun i => #[11,822,11][i]?.getD 0
  accumulator := fun i => #[11,11,822,822][i]?.getD 0
theorem rotationDot_9_12_checked : rotationDot_9_12.ExtendedCheck nodes 3 := by decide
def rotationDot_9_13 : DotRecipe where
  left := fun i => #[11,14,11][i]?.getD 0
  right := fun i => #[488,11,15][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_9_13_checked : rotationDot_9_13.ExtendedCheck nodes 3 := by decide
def rotationDot_9_14 : DotRecipe where
  left := fun i => #[11,14,11][i]?.getD 0
  right := fun i => #[16,111,11][i]?.getD 0
  product := fun i => #[11,2197,11][i]?.getD 0
  accumulator := fun i => #[11,11,2197,2197][i]?.getD 0
theorem rotationDot_9_14_checked : rotationDot_9_14.ExtendedCheck nodes 3 := by decide
def rotationDot_9_15 : DotRecipe where
  left := fun i => #[11,14,11][i]?.getD 0
  right := fun i => #[11,14,265][i]?.getD 0
  product := fun i => #[11,822,11][i]?.getD 0
  accumulator := fun i => #[11,11,822,822][i]?.getD 0
theorem rotationDot_9_15_checked : rotationDot_9_15.ExtendedCheck nodes 3 := by decide
def rotationDot_9_16 : DotRecipe where
  left := fun i => #[11,14,11][i]?.getD 0
  right := fun i => #[488,11,15][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_9_16_checked : rotationDot_9_16.ExtendedCheck nodes 3 := by decide
def rotationDot_9_17 : DotRecipe where
  left := fun i => #[11,14,11][i]?.getD 0
  right := fun i => #[17,111,11][i]?.getD 0
  product := fun i => #[11,2197,11][i]?.getD 0
  accumulator := fun i => #[11,11,2197,2197][i]?.getD 0
theorem rotationDot_9_17_checked : rotationDot_9_17.ExtendedCheck nodes 3 := by decide
def rotationDot_9_18 : DotRecipe where
  left := fun i => #[11,14,11][i]?.getD 0
  right := fun i => #[11,11,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_9_18_checked : rotationDot_9_18.ExtendedCheck nodes 3 := by decide
def rotationDot_9_19 : DotRecipe where
  left := fun i => #[11,14,11][i]?.getD 0
  right := fun i => #[11,11,18][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_9_19_checked : rotationDot_9_19.ExtendedCheck nodes 3 := by decide
def rotationDot_9_20 : DotRecipe where
  left := fun i => #[11,14,11][i]?.getD 0
  right := fun i => #[11,2,11][i]?.getD 0
  product := fun i => #[11,14,11][i]?.getD 0
  accumulator := fun i => #[11,11,14,14][i]?.getD 0
theorem rotationDot_9_20_checked : rotationDot_9_20.ExtendedCheck nodes 3 := by decide
def rotationDot_9_21 : DotRecipe where
  left := fun i => #[11,14,11][i]?.getD 0
  right := fun i => #[11,11,19][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_9_21_checked : rotationDot_9_21.ExtendedCheck nodes 3 := by decide
def rotationDot_9_22 : DotRecipe where
  left := fun i => #[11,14,11][i]?.getD 0
  right := fun i => #[11,11,9][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_9_22_checked : rotationDot_9_22.ExtendedCheck nodes 3 := by decide
def rotationDot_9_23 : DotRecipe where
  left := fun i => #[11,14,11][i]?.getD 0
  right := fun i => #[13,12,11][i]?.getD 0
  product := fun i => #[11,2208,11][i]?.getD 0
  accumulator := fun i => #[11,11,2208,2208][i]?.getD 0
theorem rotationDot_9_23_checked : rotationDot_9_23.ExtendedCheck nodes 3 := by decide
def rotationDot_9_24 : DotRecipe where
  left := fun i => #[11,14,11][i]?.getD 0
  right := fun i => #[11,11,1926][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_9_24_checked : rotationDot_9_24.ExtendedCheck nodes 3 := by decide
def rotationDot_9_25 : DotRecipe where
  left := fun i => #[11,14,11][i]?.getD 0
  right := fun i => #[11,11,9][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_9_25_checked : rotationDot_9_25.ExtendedCheck nodes 3 := by decide
def rotationDot_9_26 : DotRecipe where
  left := fun i => #[11,14,11][i]?.getD 0
  right := fun i => #[19,12,11][i]?.getD 0
  product := fun i => #[11,2208,11][i]?.getD 0
  accumulator := fun i => #[11,11,2208,2208][i]?.getD 0
theorem rotationDot_9_26_checked : rotationDot_9_26.ExtendedCheck nodes 3 := by decide
def rotationDotsRow9 : Array DotRecipe := #[rotationDot_9_0,rotationDot_9_1,rotationDot_9_2,rotationDot_9_3,rotationDot_9_4,rotationDot_9_5,rotationDot_9_6,rotationDot_9_7,rotationDot_9_8,rotationDot_9_9,rotationDot_9_10,rotationDot_9_11,rotationDot_9_12,rotationDot_9_13,rotationDot_9_14,rotationDot_9_15,rotationDot_9_16,rotationDot_9_17,rotationDot_9_18,rotationDot_9_19,rotationDot_9_20,rotationDot_9_21,rotationDot_9_22,rotationDot_9_23,rotationDot_9_24,rotationDot_9_25,rotationDot_9_26]
theorem rotationDotsRow9_checked (j : Fin 27) :
    (rotationDotsRow9[j.val]?.getD rotationDot_0_0).ExtendedCheck nodes 3 := by
  fin_cases j
  · exact rotationDot_9_0_checked
  · exact rotationDot_9_1_checked
  · exact rotationDot_9_2_checked
  · exact rotationDot_9_3_checked
  · exact rotationDot_9_4_checked
  · exact rotationDot_9_5_checked
  · exact rotationDot_9_6_checked
  · exact rotationDot_9_7_checked
  · exact rotationDot_9_8_checked
  · exact rotationDot_9_9_checked
  · exact rotationDot_9_10_checked
  · exact rotationDot_9_11_checked
  · exact rotationDot_9_12_checked
  · exact rotationDot_9_13_checked
  · exact rotationDot_9_14_checked
  · exact rotationDot_9_15_checked
  · exact rotationDot_9_16_checked
  · exact rotationDot_9_17_checked
  · exact rotationDot_9_18_checked
  · exact rotationDot_9_19_checked
  · exact rotationDot_9_20_checked
  · exact rotationDot_9_21_checked
  · exact rotationDot_9_22_checked
  · exact rotationDot_9_23_checked
  · exact rotationDot_9_24_checked
  · exact rotationDot_9_25_checked
  · exact rotationDot_9_26_checked
def rotationDot_10_0 : DotRecipe where
  left := fun i => #[488,11,0][i]?.getD 0
  right := fun i => #[11,5,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_10_0_checked : rotationDot_10_0.ExtendedCheck nodes 3 := by decide
def rotationDot_10_1 : DotRecipe where
  left := fun i => #[488,11,0][i]?.getD 0
  right := fun i => #[14,11,0][i]?.getD 0
  product := fun i => #[2211,11,1][i]?.getD 0
  accumulator := fun i => #[11,2211,2211,2212][i]?.getD 0
theorem rotationDot_10_1_checked : rotationDot_10_1.ExtendedCheck nodes 3 := by decide
def rotationDot_10_2 : DotRecipe where
  left := fun i => #[488,11,0][i]?.getD 0
  right := fun i => #[11,20,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_10_2_checked : rotationDot_10_2.ExtendedCheck nodes 3 := by decide
def rotationDot_10_3 : DotRecipe where
  left := fun i => #[488,11,0][i]?.getD 0
  right := fun i => #[11,5,113][i]?.getD 0
  product := fun i => #[11,11,1949][i]?.getD 0
  accumulator := fun i => #[11,11,11,1949][i]?.getD 0
theorem rotationDot_10_3_checked : rotationDot_10_3.ExtendedCheck nodes 3 := by decide
def rotationDot_10_4 : DotRecipe where
  left := fun i => #[488,11,0][i]?.getD 0
  right := fun i => #[14,11,15][i]?.getD 0
  product := fun i => #[2211,11,1951][i]?.getD 0
  accumulator := fun i => #[11,2211,2211,2215][i]?.getD 0
theorem rotationDot_10_4_checked : rotationDot_10_4.ExtendedCheck nodes 3 := by decide
def rotationDot_10_5 : DotRecipe where
  left := fun i => #[488,11,0][i]?.getD 0
  right := fun i => #[16,111,11][i]?.getD 0
  product := fun i => #[2217,11,11][i]?.getD 0
  accumulator := fun i => #[11,2217,2217,2217][i]?.getD 0
theorem rotationDot_10_5_checked : rotationDot_10_5.ExtendedCheck nodes 3 := by decide
def rotationDot_10_6 : DotRecipe where
  left := fun i => #[488,11,0][i]?.getD 0
  right := fun i => #[11,5,265][i]?.getD 0
  product := fun i => #[11,11,1956][i]?.getD 0
  accumulator := fun i => #[11,11,11,1956][i]?.getD 0
theorem rotationDot_10_6_checked : rotationDot_10_6.ExtendedCheck nodes 3 := by decide
def rotationDot_10_7 : DotRecipe where
  left := fun i => #[488,11,0][i]?.getD 0
  right := fun i => #[14,11,15][i]?.getD 0
  product := fun i => #[2211,11,1951][i]?.getD 0
  accumulator := fun i => #[11,2211,2211,2215][i]?.getD 0
theorem rotationDot_10_7_checked : rotationDot_10_7.ExtendedCheck nodes 3 := by decide
def rotationDot_10_8 : DotRecipe where
  left := fun i => #[488,11,0][i]?.getD 0
  right := fun i => #[17,111,11][i]?.getD 0
  product := fun i => #[2221,11,11][i]?.getD 0
  accumulator := fun i => #[11,2221,2221,2221][i]?.getD 0
theorem rotationDot_10_8_checked : rotationDot_10_8.ExtendedCheck nodes 3 := by decide
def rotationDot_10_9 : DotRecipe where
  left := fun i => #[488,11,0][i]?.getD 0
  right := fun i => #[11,14,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_10_9_checked : rotationDot_10_9.ExtendedCheck nodes 3 := by decide
def rotationDot_10_10 : DotRecipe where
  left := fun i => #[488,11,0][i]?.getD 0
  right := fun i => #[488,11,0][i]?.getD 0
  product := fun i => #[966,11,1][i]?.getD 0
  accumulator := fun i => #[11,966,966,2223][i]?.getD 0
theorem rotationDot_10_10_checked : rotationDot_10_10.ExtendedCheck nodes 3 := by decide
def rotationDot_10_11 : DotRecipe where
  left := fun i => #[488,11,0][i]?.getD 0
  right := fun i => #[11,20,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_10_11_checked : rotationDot_10_11.ExtendedCheck nodes 3 := by decide
def rotationDot_10_12 : DotRecipe where
  left := fun i => #[488,11,0][i]?.getD 0
  right := fun i => #[11,14,113][i]?.getD 0
  product := fun i => #[11,11,1949][i]?.getD 0
  accumulator := fun i => #[11,11,11,1949][i]?.getD 0
theorem rotationDot_10_12_checked : rotationDot_10_12.ExtendedCheck nodes 3 := by decide
def rotationDot_10_13 : DotRecipe where
  left := fun i => #[488,11,0][i]?.getD 0
  right := fun i => #[488,11,15][i]?.getD 0
  product := fun i => #[966,11,1951][i]?.getD 0
  accumulator := fun i => #[11,966,966,2226][i]?.getD 0
theorem rotationDot_10_13_checked : rotationDot_10_13.ExtendedCheck nodes 3 := by decide
def rotationDot_10_14 : DotRecipe where
  left := fun i => #[488,11,0][i]?.getD 0
  right := fun i => #[16,111,11][i]?.getD 0
  product := fun i => #[2217,11,11][i]?.getD 0
  accumulator := fun i => #[11,2217,2217,2217][i]?.getD 0
theorem rotationDot_10_14_checked : rotationDot_10_14.ExtendedCheck nodes 3 := by decide
def rotationDot_10_15 : DotRecipe where
  left := fun i => #[488,11,0][i]?.getD 0
  right := fun i => #[11,14,265][i]?.getD 0
  product := fun i => #[11,11,1956][i]?.getD 0
  accumulator := fun i => #[11,11,11,1956][i]?.getD 0
theorem rotationDot_10_15_checked : rotationDot_10_15.ExtendedCheck nodes 3 := by decide
def rotationDot_10_16 : DotRecipe where
  left := fun i => #[488,11,0][i]?.getD 0
  right := fun i => #[488,11,15][i]?.getD 0
  product := fun i => #[966,11,1951][i]?.getD 0
  accumulator := fun i => #[11,966,966,2226][i]?.getD 0
theorem rotationDot_10_16_checked : rotationDot_10_16.ExtendedCheck nodes 3 := by decide
def rotationDot_10_17 : DotRecipe where
  left := fun i => #[488,11,0][i]?.getD 0
  right := fun i => #[17,111,11][i]?.getD 0
  product := fun i => #[2221,11,11][i]?.getD 0
  accumulator := fun i => #[11,2221,2221,2221][i]?.getD 0
theorem rotationDot_10_17_checked : rotationDot_10_17.ExtendedCheck nodes 3 := by decide
def rotationDot_10_18 : DotRecipe where
  left := fun i => #[488,11,0][i]?.getD 0
  right := fun i => #[11,11,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_10_18_checked : rotationDot_10_18.ExtendedCheck nodes 3 := by decide
def rotationDot_10_19 : DotRecipe where
  left := fun i => #[488,11,0][i]?.getD 0
  right := fun i => #[11,11,18][i]?.getD 0
  product := fun i => #[11,11,1971][i]?.getD 0
  accumulator := fun i => #[11,11,11,1971][i]?.getD 0
theorem rotationDot_10_19_checked : rotationDot_10_19.ExtendedCheck nodes 3 := by decide
def rotationDot_10_20 : DotRecipe where
  left := fun i => #[488,11,0][i]?.getD 0
  right := fun i => #[11,2,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_10_20_checked : rotationDot_10_20.ExtendedCheck nodes 3 := by decide
def rotationDot_10_21 : DotRecipe where
  left := fun i => #[488,11,0][i]?.getD 0
  right := fun i => #[11,11,19][i]?.getD 0
  product := fun i => #[11,11,1973][i]?.getD 0
  accumulator := fun i => #[11,11,11,1973][i]?.getD 0
theorem rotationDot_10_21_checked : rotationDot_10_21.ExtendedCheck nodes 3 := by decide
def rotationDot_10_22 : DotRecipe where
  left := fun i => #[488,11,0][i]?.getD 0
  right := fun i => #[11,11,9][i]?.getD 0
  product := fun i => #[11,11,1975][i]?.getD 0
  accumulator := fun i => #[11,11,11,1975][i]?.getD 0
theorem rotationDot_10_22_checked : rotationDot_10_22.ExtendedCheck nodes 3 := by decide
def rotationDot_10_23 : DotRecipe where
  left := fun i => #[488,11,0][i]?.getD 0
  right := fun i => #[13,12,11][i]?.getD 0
  product := fun i => #[2235,11,11][i]?.getD 0
  accumulator := fun i => #[11,2235,2235,2235][i]?.getD 0
theorem rotationDot_10_23_checked : rotationDot_10_23.ExtendedCheck nodes 3 := by decide
def rotationDot_10_24 : DotRecipe where
  left := fun i => #[488,11,0][i]?.getD 0
  right := fun i => #[11,11,1926][i]?.getD 0
  product := fun i => #[11,11,1979][i]?.getD 0
  accumulator := fun i => #[11,11,11,1979][i]?.getD 0
theorem rotationDot_10_24_checked : rotationDot_10_24.ExtendedCheck nodes 3 := by decide
def rotationDot_10_25 : DotRecipe where
  left := fun i => #[488,11,0][i]?.getD 0
  right := fun i => #[11,11,9][i]?.getD 0
  product := fun i => #[11,11,1975][i]?.getD 0
  accumulator := fun i => #[11,11,11,1975][i]?.getD 0
theorem rotationDot_10_25_checked : rotationDot_10_25.ExtendedCheck nodes 3 := by decide
def rotationDot_10_26 : DotRecipe where
  left := fun i => #[488,11,0][i]?.getD 0
  right := fun i => #[19,12,11][i]?.getD 0
  product := fun i => #[2239,11,11][i]?.getD 0
  accumulator := fun i => #[11,2239,2239,2239][i]?.getD 0
theorem rotationDot_10_26_checked : rotationDot_10_26.ExtendedCheck nodes 3 := by decide
def rotationDotsRow10 : Array DotRecipe := #[rotationDot_10_0,rotationDot_10_1,rotationDot_10_2,rotationDot_10_3,rotationDot_10_4,rotationDot_10_5,rotationDot_10_6,rotationDot_10_7,rotationDot_10_8,rotationDot_10_9,rotationDot_10_10,rotationDot_10_11,rotationDot_10_12,rotationDot_10_13,rotationDot_10_14,rotationDot_10_15,rotationDot_10_16,rotationDot_10_17,rotationDot_10_18,rotationDot_10_19,rotationDot_10_20,rotationDot_10_21,rotationDot_10_22,rotationDot_10_23,rotationDot_10_24,rotationDot_10_25,rotationDot_10_26]
theorem rotationDotsRow10_checked (j : Fin 27) :
    (rotationDotsRow10[j.val]?.getD rotationDot_0_0).ExtendedCheck nodes 3 := by
  fin_cases j
  · exact rotationDot_10_0_checked
  · exact rotationDot_10_1_checked
  · exact rotationDot_10_2_checked
  · exact rotationDot_10_3_checked
  · exact rotationDot_10_4_checked
  · exact rotationDot_10_5_checked
  · exact rotationDot_10_6_checked
  · exact rotationDot_10_7_checked
  · exact rotationDot_10_8_checked
  · exact rotationDot_10_9_checked
  · exact rotationDot_10_10_checked
  · exact rotationDot_10_11_checked
  · exact rotationDot_10_12_checked
  · exact rotationDot_10_13_checked
  · exact rotationDot_10_14_checked
  · exact rotationDot_10_15_checked
  · exact rotationDot_10_16_checked
  · exact rotationDot_10_17_checked
  · exact rotationDot_10_18_checked
  · exact rotationDot_10_19_checked
  · exact rotationDot_10_20_checked
  · exact rotationDot_10_21_checked
  · exact rotationDot_10_22_checked
  · exact rotationDot_10_23_checked
  · exact rotationDot_10_24_checked
  · exact rotationDot_10_25_checked
  · exact rotationDot_10_26_checked
def rotationDot_11_0 : DotRecipe where
  left := fun i => #[11,20,11][i]?.getD 0
  right := fun i => #[11,5,11][i]?.getD 0
  product := fun i => #[11,1984,11][i]?.getD 0
  accumulator := fun i => #[11,11,1984,1984][i]?.getD 0
theorem rotationDot_11_0_checked : rotationDot_11_0.ExtendedCheck nodes 3 := by decide
def rotationDot_11_1 : DotRecipe where
  left := fun i => #[11,20,11][i]?.getD 0
  right := fun i => #[14,11,0][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_11_1_checked : rotationDot_11_1.ExtendedCheck nodes 3 := by decide
def rotationDot_11_2 : DotRecipe where
  left := fun i => #[11,20,11][i]?.getD 0
  right := fun i => #[11,20,11][i]?.getD 0
  product := fun i => #[11,1986,11][i]?.getD 0
  accumulator := fun i => #[11,11,1986,1986][i]?.getD 0
theorem rotationDot_11_2_checked : rotationDot_11_2.ExtendedCheck nodes 3 := by decide
def rotationDot_11_3 : DotRecipe where
  left := fun i => #[11,20,11][i]?.getD 0
  right := fun i => #[11,5,113][i]?.getD 0
  product := fun i => #[11,1984,11][i]?.getD 0
  accumulator := fun i => #[11,11,1984,1984][i]?.getD 0
theorem rotationDot_11_3_checked : rotationDot_11_3.ExtendedCheck nodes 3 := by decide
def rotationDot_11_4 : DotRecipe where
  left := fun i => #[11,20,11][i]?.getD 0
  right := fun i => #[14,11,15][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_11_4_checked : rotationDot_11_4.ExtendedCheck nodes 3 := by decide
def rotationDot_11_5 : DotRecipe where
  left := fun i => #[11,20,11][i]?.getD 0
  right := fun i => #[16,111,11][i]?.getD 0
  product := fun i => #[11,1989,11][i]?.getD 0
  accumulator := fun i => #[11,11,1989,1989][i]?.getD 0
theorem rotationDot_11_5_checked : rotationDot_11_5.ExtendedCheck nodes 3 := by decide
def rotationDot_11_6 : DotRecipe where
  left := fun i => #[11,20,11][i]?.getD 0
  right := fun i => #[11,5,265][i]?.getD 0
  product := fun i => #[11,1984,11][i]?.getD 0
  accumulator := fun i => #[11,11,1984,1984][i]?.getD 0
theorem rotationDot_11_6_checked : rotationDot_11_6.ExtendedCheck nodes 3 := by decide
def rotationDot_11_7 : DotRecipe where
  left := fun i => #[11,20,11][i]?.getD 0
  right := fun i => #[14,11,15][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_11_7_checked : rotationDot_11_7.ExtendedCheck nodes 3 := by decide
def rotationDot_11_8 : DotRecipe where
  left := fun i => #[11,20,11][i]?.getD 0
  right := fun i => #[17,111,11][i]?.getD 0
  product := fun i => #[11,1989,11][i]?.getD 0
  accumulator := fun i => #[11,11,1989,1989][i]?.getD 0
theorem rotationDot_11_8_checked : rotationDot_11_8.ExtendedCheck nodes 3 := by decide
def rotationDot_11_9 : DotRecipe where
  left := fun i => #[11,20,11][i]?.getD 0
  right := fun i => #[11,14,11][i]?.getD 0
  product := fun i => #[11,1993,11][i]?.getD 0
  accumulator := fun i => #[11,11,1993,1993][i]?.getD 0
theorem rotationDot_11_9_checked : rotationDot_11_9.ExtendedCheck nodes 3 := by decide
def rotationDot_11_10 : DotRecipe where
  left := fun i => #[11,20,11][i]?.getD 0
  right := fun i => #[488,11,0][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_11_10_checked : rotationDot_11_10.ExtendedCheck nodes 3 := by decide
def rotationDot_11_11 : DotRecipe where
  left := fun i => #[11,20,11][i]?.getD 0
  right := fun i => #[11,20,11][i]?.getD 0
  product := fun i => #[11,1986,11][i]?.getD 0
  accumulator := fun i => #[11,11,1986,1986][i]?.getD 0
theorem rotationDot_11_11_checked : rotationDot_11_11.ExtendedCheck nodes 3 := by decide
def rotationDot_11_12 : DotRecipe where
  left := fun i => #[11,20,11][i]?.getD 0
  right := fun i => #[11,14,113][i]?.getD 0
  product := fun i => #[11,1993,11][i]?.getD 0
  accumulator := fun i => #[11,11,1993,1993][i]?.getD 0
theorem rotationDot_11_12_checked : rotationDot_11_12.ExtendedCheck nodes 3 := by decide
def rotationDot_11_13 : DotRecipe where
  left := fun i => #[11,20,11][i]?.getD 0
  right := fun i => #[488,11,15][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_11_13_checked : rotationDot_11_13.ExtendedCheck nodes 3 := by decide
def rotationDot_11_14 : DotRecipe where
  left := fun i => #[11,20,11][i]?.getD 0
  right := fun i => #[16,111,11][i]?.getD 0
  product := fun i => #[11,1989,11][i]?.getD 0
  accumulator := fun i => #[11,11,1989,1989][i]?.getD 0
theorem rotationDot_11_14_checked : rotationDot_11_14.ExtendedCheck nodes 3 := by decide
def rotationDot_11_15 : DotRecipe where
  left := fun i => #[11,20,11][i]?.getD 0
  right := fun i => #[11,14,265][i]?.getD 0
  product := fun i => #[11,1993,11][i]?.getD 0
  accumulator := fun i => #[11,11,1993,1993][i]?.getD 0
theorem rotationDot_11_15_checked : rotationDot_11_15.ExtendedCheck nodes 3 := by decide
def rotationDot_11_16 : DotRecipe where
  left := fun i => #[11,20,11][i]?.getD 0
  right := fun i => #[488,11,15][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_11_16_checked : rotationDot_11_16.ExtendedCheck nodes 3 := by decide
def rotationDot_11_17 : DotRecipe where
  left := fun i => #[11,20,11][i]?.getD 0
  right := fun i => #[17,111,11][i]?.getD 0
  product := fun i => #[11,1989,11][i]?.getD 0
  accumulator := fun i => #[11,11,1989,1989][i]?.getD 0
theorem rotationDot_11_17_checked : rotationDot_11_17.ExtendedCheck nodes 3 := by decide
def rotationDot_11_18 : DotRecipe where
  left := fun i => #[11,20,11][i]?.getD 0
  right := fun i => #[11,11,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_11_18_checked : rotationDot_11_18.ExtendedCheck nodes 3 := by decide
def rotationDot_11_19 : DotRecipe where
  left := fun i => #[11,20,11][i]?.getD 0
  right := fun i => #[11,11,18][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_11_19_checked : rotationDot_11_19.ExtendedCheck nodes 3 := by decide
def rotationDot_11_20 : DotRecipe where
  left := fun i => #[11,20,11][i]?.getD 0
  right := fun i => #[11,2,11][i]?.getD 0
  product := fun i => #[11,20,11][i]?.getD 0
  accumulator := fun i => #[11,11,20,20][i]?.getD 0
theorem rotationDot_11_20_checked : rotationDot_11_20.ExtendedCheck nodes 3 := by decide
def rotationDot_11_21 : DotRecipe where
  left := fun i => #[11,20,11][i]?.getD 0
  right := fun i => #[11,11,19][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_11_21_checked : rotationDot_11_21.ExtendedCheck nodes 3 := by decide
def rotationDot_11_22 : DotRecipe where
  left := fun i => #[11,20,11][i]?.getD 0
  right := fun i => #[11,11,9][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_11_22_checked : rotationDot_11_22.ExtendedCheck nodes 3 := by decide
def rotationDot_11_23 : DotRecipe where
  left := fun i => #[11,20,11][i]?.getD 0
  right := fun i => #[13,12,11][i]?.getD 0
  product := fun i => #[11,2001,11][i]?.getD 0
  accumulator := fun i => #[11,11,2001,2001][i]?.getD 0
theorem rotationDot_11_23_checked : rotationDot_11_23.ExtendedCheck nodes 3 := by decide
def rotationDot_11_24 : DotRecipe where
  left := fun i => #[11,20,11][i]?.getD 0
  right := fun i => #[11,11,1926][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_11_24_checked : rotationDot_11_24.ExtendedCheck nodes 3 := by decide
def rotationDot_11_25 : DotRecipe where
  left := fun i => #[11,20,11][i]?.getD 0
  right := fun i => #[11,11,9][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_11_25_checked : rotationDot_11_25.ExtendedCheck nodes 3 := by decide
def rotationDot_11_26 : DotRecipe where
  left := fun i => #[11,20,11][i]?.getD 0
  right := fun i => #[19,12,11][i]?.getD 0
  product := fun i => #[11,2001,11][i]?.getD 0
  accumulator := fun i => #[11,11,2001,2001][i]?.getD 0
theorem rotationDot_11_26_checked : rotationDot_11_26.ExtendedCheck nodes 3 := by decide
def rotationDotsRow11 : Array DotRecipe := #[rotationDot_11_0,rotationDot_11_1,rotationDot_11_2,rotationDot_11_3,rotationDot_11_4,rotationDot_11_5,rotationDot_11_6,rotationDot_11_7,rotationDot_11_8,rotationDot_11_9,rotationDot_11_10,rotationDot_11_11,rotationDot_11_12,rotationDot_11_13,rotationDot_11_14,rotationDot_11_15,rotationDot_11_16,rotationDot_11_17,rotationDot_11_18,rotationDot_11_19,rotationDot_11_20,rotationDot_11_21,rotationDot_11_22,rotationDot_11_23,rotationDot_11_24,rotationDot_11_25,rotationDot_11_26]
theorem rotationDotsRow11_checked (j : Fin 27) :
    (rotationDotsRow11[j.val]?.getD rotationDot_0_0).ExtendedCheck nodes 3 := by
  fin_cases j
  · exact rotationDot_11_0_checked
  · exact rotationDot_11_1_checked
  · exact rotationDot_11_2_checked
  · exact rotationDot_11_3_checked
  · exact rotationDot_11_4_checked
  · exact rotationDot_11_5_checked
  · exact rotationDot_11_6_checked
  · exact rotationDot_11_7_checked
  · exact rotationDot_11_8_checked
  · exact rotationDot_11_9_checked
  · exact rotationDot_11_10_checked
  · exact rotationDot_11_11_checked
  · exact rotationDot_11_12_checked
  · exact rotationDot_11_13_checked
  · exact rotationDot_11_14_checked
  · exact rotationDot_11_15_checked
  · exact rotationDot_11_16_checked
  · exact rotationDot_11_17_checked
  · exact rotationDot_11_18_checked
  · exact rotationDot_11_19_checked
  · exact rotationDot_11_20_checked
  · exact rotationDot_11_21_checked
  · exact rotationDot_11_22_checked
  · exact rotationDot_11_23_checked
  · exact rotationDot_11_24_checked
  · exact rotationDot_11_25_checked
  · exact rotationDot_11_26_checked
def rotationDot_12_0 : DotRecipe where
  left := fun i => #[11,14,113][i]?.getD 0
  right := fun i => #[11,5,11][i]?.getD 0
  product := fun i => #[11,2192,11][i]?.getD 0
  accumulator := fun i => #[11,11,2192,2192][i]?.getD 0
theorem rotationDot_12_0_checked : rotationDot_12_0.ExtendedCheck nodes 3 := by decide
def rotationDot_12_1 : DotRecipe where
  left := fun i => #[11,14,113][i]?.getD 0
  right := fun i => #[14,11,0][i]?.getD 0
  product := fun i => #[11,11,2004][i]?.getD 0
  accumulator := fun i => #[11,11,11,2004][i]?.getD 0
theorem rotationDot_12_1_checked : rotationDot_12_1.ExtendedCheck nodes 3 := by decide
def rotationDot_12_2 : DotRecipe where
  left := fun i => #[11,14,113][i]?.getD 0
  right := fun i => #[11,20,11][i]?.getD 0
  product := fun i => #[11,2194,11][i]?.getD 0
  accumulator := fun i => #[11,11,2194,2194][i]?.getD 0
theorem rotationDot_12_2_checked : rotationDot_12_2.ExtendedCheck nodes 3 := by decide
def rotationDot_12_3 : DotRecipe where
  left := fun i => #[11,14,113][i]?.getD 0
  right := fun i => #[11,5,113][i]?.getD 0
  product := fun i => #[11,2192,211][i]?.getD 0
  accumulator := fun i => #[11,11,2192,2258][i]?.getD 0
theorem rotationDot_12_3_checked : rotationDot_12_3.ExtendedCheck nodes 3 := by decide
def rotationDot_12_4 : DotRecipe where
  left := fun i => #[11,14,113][i]?.getD 0
  right := fun i => #[14,11,15][i]?.getD 0
  product := fun i => #[11,11,2009][i]?.getD 0
  accumulator := fun i => #[11,11,11,2009][i]?.getD 0
theorem rotationDot_12_4_checked : rotationDot_12_4.ExtendedCheck nodes 3 := by decide
def rotationDot_12_5 : DotRecipe where
  left := fun i => #[11,14,113][i]?.getD 0
  right := fun i => #[16,111,11][i]?.getD 0
  product := fun i => #[11,2197,11][i]?.getD 0
  accumulator := fun i => #[11,11,2197,2197][i]?.getD 0
theorem rotationDot_12_5_checked : rotationDot_12_5.ExtendedCheck nodes 3 := by decide
def rotationDot_12_6 : DotRecipe where
  left := fun i => #[11,14,113][i]?.getD 0
  right := fun i => #[11,5,265][i]?.getD 0
  product := fun i => #[11,2192,2012][i]?.getD 0
  accumulator := fun i => #[11,11,2192,2261][i]?.getD 0
theorem rotationDot_12_6_checked : rotationDot_12_6.ExtendedCheck nodes 3 := by decide
def rotationDot_12_7 : DotRecipe where
  left := fun i => #[11,14,113][i]?.getD 0
  right := fun i => #[14,11,15][i]?.getD 0
  product := fun i => #[11,11,2009][i]?.getD 0
  accumulator := fun i => #[11,11,11,2009][i]?.getD 0
theorem rotationDot_12_7_checked : rotationDot_12_7.ExtendedCheck nodes 3 := by decide
def rotationDot_12_8 : DotRecipe where
  left := fun i => #[11,14,113][i]?.getD 0
  right := fun i => #[17,111,11][i]?.getD 0
  product := fun i => #[11,2197,11][i]?.getD 0
  accumulator := fun i => #[11,11,2197,2197][i]?.getD 0
theorem rotationDot_12_8_checked : rotationDot_12_8.ExtendedCheck nodes 3 := by decide
def rotationDot_12_9 : DotRecipe where
  left := fun i => #[11,14,113][i]?.getD 0
  right := fun i => #[11,14,11][i]?.getD 0
  product := fun i => #[11,822,11][i]?.getD 0
  accumulator := fun i => #[11,11,822,822][i]?.getD 0
theorem rotationDot_12_9_checked : rotationDot_12_9.ExtendedCheck nodes 3 := by decide
def rotationDot_12_10 : DotRecipe where
  left := fun i => #[11,14,113][i]?.getD 0
  right := fun i => #[488,11,0][i]?.getD 0
  product := fun i => #[11,11,2004][i]?.getD 0
  accumulator := fun i => #[11,11,11,2004][i]?.getD 0
theorem rotationDot_12_10_checked : rotationDot_12_10.ExtendedCheck nodes 3 := by decide
def rotationDot_12_11 : DotRecipe where
  left := fun i => #[11,14,113][i]?.getD 0
  right := fun i => #[11,20,11][i]?.getD 0
  product := fun i => #[11,2194,11][i]?.getD 0
  accumulator := fun i => #[11,11,2194,2194][i]?.getD 0
theorem rotationDot_12_11_checked : rotationDot_12_11.ExtendedCheck nodes 3 := by decide
def rotationDot_12_12 : DotRecipe where
  left := fun i => #[11,14,113][i]?.getD 0
  right := fun i => #[11,14,113][i]?.getD 0
  product := fun i => #[11,822,211][i]?.getD 0
  accumulator := fun i => #[11,11,822,2267][i]?.getD 0
theorem rotationDot_12_12_checked : rotationDot_12_12.ExtendedCheck nodes 3 := by decide
def rotationDot_12_13 : DotRecipe where
  left := fun i => #[11,14,113][i]?.getD 0
  right := fun i => #[488,11,15][i]?.getD 0
  product := fun i => #[11,11,2009][i]?.getD 0
  accumulator := fun i => #[11,11,11,2009][i]?.getD 0
theorem rotationDot_12_13_checked : rotationDot_12_13.ExtendedCheck nodes 3 := by decide
def rotationDot_12_14 : DotRecipe where
  left := fun i => #[11,14,113][i]?.getD 0
  right := fun i => #[16,111,11][i]?.getD 0
  product := fun i => #[11,2197,11][i]?.getD 0
  accumulator := fun i => #[11,11,2197,2197][i]?.getD 0
theorem rotationDot_12_14_checked : rotationDot_12_14.ExtendedCheck nodes 3 := by decide
def rotationDot_12_15 : DotRecipe where
  left := fun i => #[11,14,113][i]?.getD 0
  right := fun i => #[11,14,265][i]?.getD 0
  product := fun i => #[11,822,2012][i]?.getD 0
  accumulator := fun i => #[11,11,822,2271][i]?.getD 0
theorem rotationDot_12_15_checked : rotationDot_12_15.ExtendedCheck nodes 3 := by decide
def rotationDot_12_16 : DotRecipe where
  left := fun i => #[11,14,113][i]?.getD 0
  right := fun i => #[488,11,15][i]?.getD 0
  product := fun i => #[11,11,2009][i]?.getD 0
  accumulator := fun i => #[11,11,11,2009][i]?.getD 0
theorem rotationDot_12_16_checked : rotationDot_12_16.ExtendedCheck nodes 3 := by decide
def rotationDot_12_17 : DotRecipe where
  left := fun i => #[11,14,113][i]?.getD 0
  right := fun i => #[17,111,11][i]?.getD 0
  product := fun i => #[11,2197,11][i]?.getD 0
  accumulator := fun i => #[11,11,2197,2197][i]?.getD 0
theorem rotationDot_12_17_checked : rotationDot_12_17.ExtendedCheck nodes 3 := by decide
def rotationDot_12_18 : DotRecipe where
  left := fun i => #[11,14,113][i]?.getD 0
  right := fun i => #[11,11,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_12_18_checked : rotationDot_12_18.ExtendedCheck nodes 3 := by decide
def rotationDot_12_19 : DotRecipe where
  left := fun i => #[11,14,113][i]?.getD 0
  right := fun i => #[11,11,18][i]?.getD 0
  product := fun i => #[11,11,2028][i]?.getD 0
  accumulator := fun i => #[11,11,11,2028][i]?.getD 0
theorem rotationDot_12_19_checked : rotationDot_12_19.ExtendedCheck nodes 3 := by decide
def rotationDot_12_20 : DotRecipe where
  left := fun i => #[11,14,113][i]?.getD 0
  right := fun i => #[11,2,11][i]?.getD 0
  product := fun i => #[11,14,11][i]?.getD 0
  accumulator := fun i => #[11,11,14,14][i]?.getD 0
theorem rotationDot_12_20_checked : rotationDot_12_20.ExtendedCheck nodes 3 := by decide
def rotationDot_12_21 : DotRecipe where
  left := fun i => #[11,14,113][i]?.getD 0
  right := fun i => #[11,11,19][i]?.getD 0
  product := fun i => #[11,11,2031][i]?.getD 0
  accumulator := fun i => #[11,11,11,2031][i]?.getD 0
theorem rotationDot_12_21_checked : rotationDot_12_21.ExtendedCheck nodes 3 := by decide
def rotationDot_12_22 : DotRecipe where
  left := fun i => #[11,14,113][i]?.getD 0
  right := fun i => #[11,11,9][i]?.getD 0
  product := fun i => #[11,11,2033][i]?.getD 0
  accumulator := fun i => #[11,11,11,2033][i]?.getD 0
theorem rotationDot_12_22_checked : rotationDot_12_22.ExtendedCheck nodes 3 := by decide
def rotationDot_12_23 : DotRecipe where
  left := fun i => #[11,14,113][i]?.getD 0
  right := fun i => #[13,12,11][i]?.getD 0
  product := fun i => #[11,2208,11][i]?.getD 0
  accumulator := fun i => #[11,11,2208,2208][i]?.getD 0
theorem rotationDot_12_23_checked : rotationDot_12_23.ExtendedCheck nodes 3 := by decide
def rotationDot_12_24 : DotRecipe where
  left := fun i => #[11,14,113][i]?.getD 0
  right := fun i => #[11,11,1926][i]?.getD 0
  product := fun i => #[11,11,2036][i]?.getD 0
  accumulator := fun i => #[11,11,11,2036][i]?.getD 0
theorem rotationDot_12_24_checked : rotationDot_12_24.ExtendedCheck nodes 3 := by decide
def rotationDot_12_25 : DotRecipe where
  left := fun i => #[11,14,113][i]?.getD 0
  right := fun i => #[11,11,9][i]?.getD 0
  product := fun i => #[11,11,2033][i]?.getD 0
  accumulator := fun i => #[11,11,11,2033][i]?.getD 0
theorem rotationDot_12_25_checked : rotationDot_12_25.ExtendedCheck nodes 3 := by decide
def rotationDot_12_26 : DotRecipe where
  left := fun i => #[11,14,113][i]?.getD 0
  right := fun i => #[19,12,11][i]?.getD 0
  product := fun i => #[11,2208,11][i]?.getD 0
  accumulator := fun i => #[11,11,2208,2208][i]?.getD 0
theorem rotationDot_12_26_checked : rotationDot_12_26.ExtendedCheck nodes 3 := by decide
def rotationDotsRow12 : Array DotRecipe := #[rotationDot_12_0,rotationDot_12_1,rotationDot_12_2,rotationDot_12_3,rotationDot_12_4,rotationDot_12_5,rotationDot_12_6,rotationDot_12_7,rotationDot_12_8,rotationDot_12_9,rotationDot_12_10,rotationDot_12_11,rotationDot_12_12,rotationDot_12_13,rotationDot_12_14,rotationDot_12_15,rotationDot_12_16,rotationDot_12_17,rotationDot_12_18,rotationDot_12_19,rotationDot_12_20,rotationDot_12_21,rotationDot_12_22,rotationDot_12_23,rotationDot_12_24,rotationDot_12_25,rotationDot_12_26]
theorem rotationDotsRow12_checked (j : Fin 27) :
    (rotationDotsRow12[j.val]?.getD rotationDot_0_0).ExtendedCheck nodes 3 := by
  fin_cases j
  · exact rotationDot_12_0_checked
  · exact rotationDot_12_1_checked
  · exact rotationDot_12_2_checked
  · exact rotationDot_12_3_checked
  · exact rotationDot_12_4_checked
  · exact rotationDot_12_5_checked
  · exact rotationDot_12_6_checked
  · exact rotationDot_12_7_checked
  · exact rotationDot_12_8_checked
  · exact rotationDot_12_9_checked
  · exact rotationDot_12_10_checked
  · exact rotationDot_12_11_checked
  · exact rotationDot_12_12_checked
  · exact rotationDot_12_13_checked
  · exact rotationDot_12_14_checked
  · exact rotationDot_12_15_checked
  · exact rotationDot_12_16_checked
  · exact rotationDot_12_17_checked
  · exact rotationDot_12_18_checked
  · exact rotationDot_12_19_checked
  · exact rotationDot_12_20_checked
  · exact rotationDot_12_21_checked
  · exact rotationDot_12_22_checked
  · exact rotationDot_12_23_checked
  · exact rotationDot_12_24_checked
  · exact rotationDot_12_25_checked
  · exact rotationDot_12_26_checked
def rotationDot_13_0 : DotRecipe where
  left := fun i => #[488,11,15][i]?.getD 0
  right := fun i => #[11,5,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_13_0_checked : rotationDot_13_0.ExtendedCheck nodes 3 := by decide
def rotationDot_13_1 : DotRecipe where
  left := fun i => #[488,11,15][i]?.getD 0
  right := fun i => #[14,11,0][i]?.getD 0
  product := fun i => #[2211,11,2040][i]?.getD 0
  accumulator := fun i => #[11,2211,2211,2283][i]?.getD 0
theorem rotationDot_13_1_checked : rotationDot_13_1.ExtendedCheck nodes 3 := by decide
def rotationDot_13_2 : DotRecipe where
  left := fun i => #[488,11,15][i]?.getD 0
  right := fun i => #[11,20,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_13_2_checked : rotationDot_13_2.ExtendedCheck nodes 3 := by decide
def rotationDot_13_3 : DotRecipe where
  left := fun i => #[488,11,15][i]?.getD 0
  right := fun i => #[11,5,113][i]?.getD 0
  product := fun i => #[11,11,2043][i]?.getD 0
  accumulator := fun i => #[11,11,11,2043][i]?.getD 0
theorem rotationDot_13_3_checked : rotationDot_13_3.ExtendedCheck nodes 3 := by decide
def rotationDot_13_4 : DotRecipe where
  left := fun i => #[488,11,15][i]?.getD 0
  right := fun i => #[14,11,15][i]?.getD 0
  product := fun i => #[2211,11,2045][i]?.getD 0
  accumulator := fun i => #[11,2211,2211,2285][i]?.getD 0
theorem rotationDot_13_4_checked : rotationDot_13_4.ExtendedCheck nodes 3 := by decide
def rotationDot_13_5 : DotRecipe where
  left := fun i => #[488,11,15][i]?.getD 0
  right := fun i => #[16,111,11][i]?.getD 0
  product := fun i => #[2217,11,11][i]?.getD 0
  accumulator := fun i => #[11,2217,2217,2217][i]?.getD 0
theorem rotationDot_13_5_checked : rotationDot_13_5.ExtendedCheck nodes 3 := by decide
def rotationDot_13_6 : DotRecipe where
  left := fun i => #[488,11,15][i]?.getD 0
  right := fun i => #[11,5,265][i]?.getD 0
  product := fun i => #[11,11,2049][i]?.getD 0
  accumulator := fun i => #[11,11,11,2049][i]?.getD 0
theorem rotationDot_13_6_checked : rotationDot_13_6.ExtendedCheck nodes 3 := by decide
def rotationDot_13_7 : DotRecipe where
  left := fun i => #[488,11,15][i]?.getD 0
  right := fun i => #[14,11,15][i]?.getD 0
  product := fun i => #[2211,11,2045][i]?.getD 0
  accumulator := fun i => #[11,2211,2211,2285][i]?.getD 0
theorem rotationDot_13_7_checked : rotationDot_13_7.ExtendedCheck nodes 3 := by decide
def rotationDot_13_8 : DotRecipe where
  left := fun i => #[488,11,15][i]?.getD 0
  right := fun i => #[17,111,11][i]?.getD 0
  product := fun i => #[2221,11,11][i]?.getD 0
  accumulator := fun i => #[11,2221,2221,2221][i]?.getD 0
theorem rotationDot_13_8_checked : rotationDot_13_8.ExtendedCheck nodes 3 := by decide
def rotationDot_13_9 : DotRecipe where
  left := fun i => #[488,11,15][i]?.getD 0
  right := fun i => #[11,14,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_13_9_checked : rotationDot_13_9.ExtendedCheck nodes 3 := by decide
def rotationDot_13_10 : DotRecipe where
  left := fun i => #[488,11,15][i]?.getD 0
  right := fun i => #[488,11,0][i]?.getD 0
  product := fun i => #[966,11,2040][i]?.getD 0
  accumulator := fun i => #[11,966,966,2291][i]?.getD 0
theorem rotationDot_13_10_checked : rotationDot_13_10.ExtendedCheck nodes 3 := by decide
def rotationDot_13_11 : DotRecipe where
  left := fun i => #[488,11,15][i]?.getD 0
  right := fun i => #[11,20,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_13_11_checked : rotationDot_13_11.ExtendedCheck nodes 3 := by decide
def rotationDot_13_12 : DotRecipe where
  left := fun i => #[488,11,15][i]?.getD 0
  right := fun i => #[11,14,113][i]?.getD 0
  product := fun i => #[11,11,2043][i]?.getD 0
  accumulator := fun i => #[11,11,11,2043][i]?.getD 0
theorem rotationDot_13_12_checked : rotationDot_13_12.ExtendedCheck nodes 3 := by decide
def rotationDot_13_13 : DotRecipe where
  left := fun i => #[488,11,15][i]?.getD 0
  right := fun i => #[488,11,15][i]?.getD 0
  product := fun i => #[966,11,2045][i]?.getD 0
  accumulator := fun i => #[11,966,966,2294][i]?.getD 0
theorem rotationDot_13_13_checked : rotationDot_13_13.ExtendedCheck nodes 3 := by decide
def rotationDot_13_14 : DotRecipe where
  left := fun i => #[488,11,15][i]?.getD 0
  right := fun i => #[16,111,11][i]?.getD 0
  product := fun i => #[2217,11,11][i]?.getD 0
  accumulator := fun i => #[11,2217,2217,2217][i]?.getD 0
theorem rotationDot_13_14_checked : rotationDot_13_14.ExtendedCheck nodes 3 := by decide
def rotationDot_13_15 : DotRecipe where
  left := fun i => #[488,11,15][i]?.getD 0
  right := fun i => #[11,14,265][i]?.getD 0
  product := fun i => #[11,11,2049][i]?.getD 0
  accumulator := fun i => #[11,11,11,2049][i]?.getD 0
theorem rotationDot_13_15_checked : rotationDot_13_15.ExtendedCheck nodes 3 := by decide
def rotationDot_13_16 : DotRecipe where
  left := fun i => #[488,11,15][i]?.getD 0
  right := fun i => #[488,11,15][i]?.getD 0
  product := fun i => #[966,11,2045][i]?.getD 0
  accumulator := fun i => #[11,966,966,2294][i]?.getD 0
theorem rotationDot_13_16_checked : rotationDot_13_16.ExtendedCheck nodes 3 := by decide
def rotationDot_13_17 : DotRecipe where
  left := fun i => #[488,11,15][i]?.getD 0
  right := fun i => #[17,111,11][i]?.getD 0
  product := fun i => #[2221,11,11][i]?.getD 0
  accumulator := fun i => #[11,2221,2221,2221][i]?.getD 0
theorem rotationDot_13_17_checked : rotationDot_13_17.ExtendedCheck nodes 3 := by decide
def rotationDot_13_18 : DotRecipe where
  left := fun i => #[488,11,15][i]?.getD 0
  right := fun i => #[11,11,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_13_18_checked : rotationDot_13_18.ExtendedCheck nodes 3 := by decide
def rotationDot_13_19 : DotRecipe where
  left := fun i => #[488,11,15][i]?.getD 0
  right := fun i => #[11,11,18][i]?.getD 0
  product := fun i => #[11,11,2062][i]?.getD 0
  accumulator := fun i => #[11,11,11,2062][i]?.getD 0
theorem rotationDot_13_19_checked : rotationDot_13_19.ExtendedCheck nodes 3 := by decide
def rotationDot_13_20 : DotRecipe where
  left := fun i => #[488,11,15][i]?.getD 0
  right := fun i => #[11,2,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_13_20_checked : rotationDot_13_20.ExtendedCheck nodes 3 := by decide
def rotationDot_13_21 : DotRecipe where
  left := fun i => #[488,11,15][i]?.getD 0
  right := fun i => #[11,11,19][i]?.getD 0
  product := fun i => #[11,11,2064][i]?.getD 0
  accumulator := fun i => #[11,11,11,2064][i]?.getD 0
theorem rotationDot_13_21_checked : rotationDot_13_21.ExtendedCheck nodes 3 := by decide
def rotationDot_13_22 : DotRecipe where
  left := fun i => #[488,11,15][i]?.getD 0
  right := fun i => #[11,11,9][i]?.getD 0
  product := fun i => #[11,11,2066][i]?.getD 0
  accumulator := fun i => #[11,11,11,2066][i]?.getD 0
theorem rotationDot_13_22_checked : rotationDot_13_22.ExtendedCheck nodes 3 := by decide
def rotationDot_13_23 : DotRecipe where
  left := fun i => #[488,11,15][i]?.getD 0
  right := fun i => #[13,12,11][i]?.getD 0
  product := fun i => #[2235,11,11][i]?.getD 0
  accumulator := fun i => #[11,2235,2235,2235][i]?.getD 0
theorem rotationDot_13_23_checked : rotationDot_13_23.ExtendedCheck nodes 3 := by decide
def rotationDot_13_24 : DotRecipe where
  left := fun i => #[488,11,15][i]?.getD 0
  right := fun i => #[11,11,1926][i]?.getD 0
  product := fun i => #[11,11,2069][i]?.getD 0
  accumulator := fun i => #[11,11,11,2069][i]?.getD 0
theorem rotationDot_13_24_checked : rotationDot_13_24.ExtendedCheck nodes 3 := by decide
def rotationDot_13_25 : DotRecipe where
  left := fun i => #[488,11,15][i]?.getD 0
  right := fun i => #[11,11,9][i]?.getD 0
  product := fun i => #[11,11,2066][i]?.getD 0
  accumulator := fun i => #[11,11,11,2066][i]?.getD 0
theorem rotationDot_13_25_checked : rotationDot_13_25.ExtendedCheck nodes 3 := by decide
def rotationDot_13_26 : DotRecipe where
  left := fun i => #[488,11,15][i]?.getD 0
  right := fun i => #[19,12,11][i]?.getD 0
  product := fun i => #[2239,11,11][i]?.getD 0
  accumulator := fun i => #[11,2239,2239,2239][i]?.getD 0
theorem rotationDot_13_26_checked : rotationDot_13_26.ExtendedCheck nodes 3 := by decide
def rotationDotsRow13 : Array DotRecipe := #[rotationDot_13_0,rotationDot_13_1,rotationDot_13_2,rotationDot_13_3,rotationDot_13_4,rotationDot_13_5,rotationDot_13_6,rotationDot_13_7,rotationDot_13_8,rotationDot_13_9,rotationDot_13_10,rotationDot_13_11,rotationDot_13_12,rotationDot_13_13,rotationDot_13_14,rotationDot_13_15,rotationDot_13_16,rotationDot_13_17,rotationDot_13_18,rotationDot_13_19,rotationDot_13_20,rotationDot_13_21,rotationDot_13_22,rotationDot_13_23,rotationDot_13_24,rotationDot_13_25,rotationDot_13_26]
theorem rotationDotsRow13_checked (j : Fin 27) :
    (rotationDotsRow13[j.val]?.getD rotationDot_0_0).ExtendedCheck nodes 3 := by
  fin_cases j
  · exact rotationDot_13_0_checked
  · exact rotationDot_13_1_checked
  · exact rotationDot_13_2_checked
  · exact rotationDot_13_3_checked
  · exact rotationDot_13_4_checked
  · exact rotationDot_13_5_checked
  · exact rotationDot_13_6_checked
  · exact rotationDot_13_7_checked
  · exact rotationDot_13_8_checked
  · exact rotationDot_13_9_checked
  · exact rotationDot_13_10_checked
  · exact rotationDot_13_11_checked
  · exact rotationDot_13_12_checked
  · exact rotationDot_13_13_checked
  · exact rotationDot_13_14_checked
  · exact rotationDot_13_15_checked
  · exact rotationDot_13_16_checked
  · exact rotationDot_13_17_checked
  · exact rotationDot_13_18_checked
  · exact rotationDot_13_19_checked
  · exact rotationDot_13_20_checked
  · exact rotationDot_13_21_checked
  · exact rotationDot_13_22_checked
  · exact rotationDot_13_23_checked
  · exact rotationDot_13_24_checked
  · exact rotationDot_13_25_checked
  · exact rotationDot_13_26_checked
def rotationDot_14_0 : DotRecipe where
  left := fun i => #[16,111,11][i]?.getD 0
  right := fun i => #[11,5,11][i]?.getD 0
  product := fun i => #[11,2073,11][i]?.getD 0
  accumulator := fun i => #[11,11,2073,2073][i]?.getD 0
theorem rotationDot_14_0_checked : rotationDot_14_0.ExtendedCheck nodes 3 := by decide
def rotationDot_14_1 : DotRecipe where
  left := fun i => #[16,111,11][i]?.getD 0
  right := fun i => #[14,11,0][i]?.getD 0
  product := fun i => #[2075,11,11][i]?.getD 0
  accumulator := fun i => #[11,2075,2075,2075][i]?.getD 0
theorem rotationDot_14_1_checked : rotationDot_14_1.ExtendedCheck nodes 3 := by decide
def rotationDot_14_2 : DotRecipe where
  left := fun i => #[16,111,11][i]?.getD 0
  right := fun i => #[11,20,11][i]?.getD 0
  product := fun i => #[11,2077,11][i]?.getD 0
  accumulator := fun i => #[11,11,2077,2077][i]?.getD 0
theorem rotationDot_14_2_checked : rotationDot_14_2.ExtendedCheck nodes 3 := by decide
def rotationDot_14_3 : DotRecipe where
  left := fun i => #[16,111,11][i]?.getD 0
  right := fun i => #[11,5,113][i]?.getD 0
  product := fun i => #[11,2073,11][i]?.getD 0
  accumulator := fun i => #[11,11,2073,2073][i]?.getD 0
theorem rotationDot_14_3_checked : rotationDot_14_3.ExtendedCheck nodes 3 := by decide
def rotationDot_14_4 : DotRecipe where
  left := fun i => #[16,111,11][i]?.getD 0
  right := fun i => #[14,11,15][i]?.getD 0
  product := fun i => #[2075,11,11][i]?.getD 0
  accumulator := fun i => #[11,2075,2075,2075][i]?.getD 0
theorem rotationDot_14_4_checked : rotationDot_14_4.ExtendedCheck nodes 3 := by decide
def rotationDot_14_5 : DotRecipe where
  left := fun i => #[16,111,11][i]?.getD 0
  right := fun i => #[16,111,11][i]?.getD 0
  product := fun i => #[24,2081,11][i]?.getD 0
  accumulator := fun i => #[11,24,2082,2082][i]?.getD 0
theorem rotationDot_14_5_checked : rotationDot_14_5.ExtendedCheck nodes 3 := by decide
def rotationDot_14_6 : DotRecipe where
  left := fun i => #[16,111,11][i]?.getD 0
  right := fun i => #[11,5,265][i]?.getD 0
  product := fun i => #[11,2073,11][i]?.getD 0
  accumulator := fun i => #[11,11,2073,2073][i]?.getD 0
theorem rotationDot_14_6_checked : rotationDot_14_6.ExtendedCheck nodes 3 := by decide
def rotationDot_14_7 : DotRecipe where
  left := fun i => #[16,111,11][i]?.getD 0
  right := fun i => #[14,11,15][i]?.getD 0
  product := fun i => #[2075,11,11][i]?.getD 0
  accumulator := fun i => #[11,2075,2075,2075][i]?.getD 0
theorem rotationDot_14_7_checked : rotationDot_14_7.ExtendedCheck nodes 3 := by decide
def rotationDot_14_8 : DotRecipe where
  left := fun i => #[16,111,11][i]?.getD 0
  right := fun i => #[17,111,11][i]?.getD 0
  product := fun i => #[2086,2081,11][i]?.getD 0
  accumulator := fun i => #[11,2086,2087,2087][i]?.getD 0
theorem rotationDot_14_8_checked : rotationDot_14_8.ExtendedCheck nodes 3 := by decide
def rotationDot_14_9 : DotRecipe where
  left := fun i => #[16,111,11][i]?.getD 0
  right := fun i => #[11,14,11][i]?.getD 0
  product := fun i => #[11,2089,11][i]?.getD 0
  accumulator := fun i => #[11,11,2089,2089][i]?.getD 0
theorem rotationDot_14_9_checked : rotationDot_14_9.ExtendedCheck nodes 3 := by decide
def rotationDot_14_10 : DotRecipe where
  left := fun i => #[16,111,11][i]?.getD 0
  right := fun i => #[488,11,0][i]?.getD 0
  product := fun i => #[2091,11,11][i]?.getD 0
  accumulator := fun i => #[11,2091,2091,2091][i]?.getD 0
theorem rotationDot_14_10_checked : rotationDot_14_10.ExtendedCheck nodes 3 := by decide
def rotationDot_14_11 : DotRecipe where
  left := fun i => #[16,111,11][i]?.getD 0
  right := fun i => #[11,20,11][i]?.getD 0
  product := fun i => #[11,2077,11][i]?.getD 0
  accumulator := fun i => #[11,11,2077,2077][i]?.getD 0
theorem rotationDot_14_11_checked : rotationDot_14_11.ExtendedCheck nodes 3 := by decide
def rotationDot_14_12 : DotRecipe where
  left := fun i => #[16,111,11][i]?.getD 0
  right := fun i => #[11,14,113][i]?.getD 0
  product := fun i => #[11,2089,11][i]?.getD 0
  accumulator := fun i => #[11,11,2089,2089][i]?.getD 0
theorem rotationDot_14_12_checked : rotationDot_14_12.ExtendedCheck nodes 3 := by decide
def rotationDot_14_13 : DotRecipe where
  left := fun i => #[16,111,11][i]?.getD 0
  right := fun i => #[488,11,15][i]?.getD 0
  product := fun i => #[2091,11,11][i]?.getD 0
  accumulator := fun i => #[11,2091,2091,2091][i]?.getD 0
theorem rotationDot_14_13_checked : rotationDot_14_13.ExtendedCheck nodes 3 := by decide
def rotationDot_14_14 : DotRecipe where
  left := fun i => #[16,111,11][i]?.getD 0
  right := fun i => #[16,111,11][i]?.getD 0
  product := fun i => #[24,2081,11][i]?.getD 0
  accumulator := fun i => #[11,24,2082,2082][i]?.getD 0
theorem rotationDot_14_14_checked : rotationDot_14_14.ExtendedCheck nodes 3 := by decide
def rotationDot_14_15 : DotRecipe where
  left := fun i => #[16,111,11][i]?.getD 0
  right := fun i => #[11,14,265][i]?.getD 0
  product := fun i => #[11,2089,11][i]?.getD 0
  accumulator := fun i => #[11,11,2089,2089][i]?.getD 0
theorem rotationDot_14_15_checked : rotationDot_14_15.ExtendedCheck nodes 3 := by decide
def rotationDot_14_16 : DotRecipe where
  left := fun i => #[16,111,11][i]?.getD 0
  right := fun i => #[488,11,15][i]?.getD 0
  product := fun i => #[2091,11,11][i]?.getD 0
  accumulator := fun i => #[11,2091,2091,2091][i]?.getD 0
theorem rotationDot_14_16_checked : rotationDot_14_16.ExtendedCheck nodes 3 := by decide
def rotationDot_14_17 : DotRecipe where
  left := fun i => #[16,111,11][i]?.getD 0
  right := fun i => #[17,111,11][i]?.getD 0
  product := fun i => #[2086,2081,11][i]?.getD 0
  accumulator := fun i => #[11,2086,2087,2087][i]?.getD 0
theorem rotationDot_14_17_checked : rotationDot_14_17.ExtendedCheck nodes 3 := by decide
def rotationDot_14_18 : DotRecipe where
  left := fun i => #[16,111,11][i]?.getD 0
  right := fun i => #[11,11,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_14_18_checked : rotationDot_14_18.ExtendedCheck nodes 3 := by decide
def rotationDot_14_19 : DotRecipe where
  left := fun i => #[16,111,11][i]?.getD 0
  right := fun i => #[11,11,18][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_14_19_checked : rotationDot_14_19.ExtendedCheck nodes 3 := by decide
def rotationDot_14_20 : DotRecipe where
  left := fun i => #[16,111,11][i]?.getD 0
  right := fun i => #[11,2,11][i]?.getD 0
  product := fun i => #[11,111,11][i]?.getD 0
  accumulator := fun i => #[11,11,111,111][i]?.getD 0
theorem rotationDot_14_20_checked : rotationDot_14_20.ExtendedCheck nodes 3 := by decide
def rotationDot_14_21 : DotRecipe where
  left := fun i => #[16,111,11][i]?.getD 0
  right := fun i => #[11,11,19][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_14_21_checked : rotationDot_14_21.ExtendedCheck nodes 3 := by decide
def rotationDot_14_22 : DotRecipe where
  left := fun i => #[16,111,11][i]?.getD 0
  right := fun i => #[11,11,9][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_14_22_checked : rotationDot_14_22.ExtendedCheck nodes 3 := by decide
def rotationDot_14_23 : DotRecipe where
  left := fun i => #[16,111,11][i]?.getD 0
  right := fun i => #[13,12,11][i]?.getD 0
  product := fun i => #[2101,2102,11][i]?.getD 0
  accumulator := fun i => #[11,2101,2103,2103][i]?.getD 0
theorem rotationDot_14_23_checked : rotationDot_14_23.ExtendedCheck nodes 3 := by decide
def rotationDot_14_24 : DotRecipe where
  left := fun i => #[16,111,11][i]?.getD 0
  right := fun i => #[11,11,1926][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_14_24_checked : rotationDot_14_24.ExtendedCheck nodes 3 := by decide
def rotationDot_14_25 : DotRecipe where
  left := fun i => #[16,111,11][i]?.getD 0
  right := fun i => #[11,11,9][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_14_25_checked : rotationDot_14_25.ExtendedCheck nodes 3 := by decide
def rotationDot_14_26 : DotRecipe where
  left := fun i => #[16,111,11][i]?.getD 0
  right := fun i => #[19,12,11][i]?.getD 0
  product := fun i => #[2105,2102,11][i]?.getD 0
  accumulator := fun i => #[11,2105,2106,2106][i]?.getD 0
theorem rotationDot_14_26_checked : rotationDot_14_26.ExtendedCheck nodes 3 := by decide
def rotationDotsRow14 : Array DotRecipe := #[rotationDot_14_0,rotationDot_14_1,rotationDot_14_2,rotationDot_14_3,rotationDot_14_4,rotationDot_14_5,rotationDot_14_6,rotationDot_14_7,rotationDot_14_8,rotationDot_14_9,rotationDot_14_10,rotationDot_14_11,rotationDot_14_12,rotationDot_14_13,rotationDot_14_14,rotationDot_14_15,rotationDot_14_16,rotationDot_14_17,rotationDot_14_18,rotationDot_14_19,rotationDot_14_20,rotationDot_14_21,rotationDot_14_22,rotationDot_14_23,rotationDot_14_24,rotationDot_14_25,rotationDot_14_26]
theorem rotationDotsRow14_checked (j : Fin 27) :
    (rotationDotsRow14[j.val]?.getD rotationDot_0_0).ExtendedCheck nodes 3 := by
  fin_cases j
  · exact rotationDot_14_0_checked
  · exact rotationDot_14_1_checked
  · exact rotationDot_14_2_checked
  · exact rotationDot_14_3_checked
  · exact rotationDot_14_4_checked
  · exact rotationDot_14_5_checked
  · exact rotationDot_14_6_checked
  · exact rotationDot_14_7_checked
  · exact rotationDot_14_8_checked
  · exact rotationDot_14_9_checked
  · exact rotationDot_14_10_checked
  · exact rotationDot_14_11_checked
  · exact rotationDot_14_12_checked
  · exact rotationDot_14_13_checked
  · exact rotationDot_14_14_checked
  · exact rotationDot_14_15_checked
  · exact rotationDot_14_16_checked
  · exact rotationDot_14_17_checked
  · exact rotationDot_14_18_checked
  · exact rotationDot_14_19_checked
  · exact rotationDot_14_20_checked
  · exact rotationDot_14_21_checked
  · exact rotationDot_14_22_checked
  · exact rotationDot_14_23_checked
  · exact rotationDot_14_24_checked
  · exact rotationDot_14_25_checked
  · exact rotationDot_14_26_checked
def rotationDot_15_0 : DotRecipe where
  left := fun i => #[11,14,265][i]?.getD 0
  right := fun i => #[11,5,11][i]?.getD 0
  product := fun i => #[11,2192,11][i]?.getD 0
  accumulator := fun i => #[11,11,2192,2192][i]?.getD 0
theorem rotationDot_15_0_checked : rotationDot_15_0.ExtendedCheck nodes 3 := by decide
def rotationDot_15_1 : DotRecipe where
  left := fun i => #[11,14,265][i]?.getD 0
  right := fun i => #[14,11,0][i]?.getD 0
  product := fun i => #[11,11,2108][i]?.getD 0
  accumulator := fun i => #[11,11,11,2108][i]?.getD 0
theorem rotationDot_15_1_checked : rotationDot_15_1.ExtendedCheck nodes 3 := by decide
def rotationDot_15_2 : DotRecipe where
  left := fun i => #[11,14,265][i]?.getD 0
  right := fun i => #[11,20,11][i]?.getD 0
  product := fun i => #[11,2194,11][i]?.getD 0
  accumulator := fun i => #[11,11,2194,2194][i]?.getD 0
theorem rotationDot_15_2_checked : rotationDot_15_2.ExtendedCheck nodes 3 := by decide
def rotationDot_15_3 : DotRecipe where
  left := fun i => #[11,14,265][i]?.getD 0
  right := fun i => #[11,5,113][i]?.getD 0
  product := fun i => #[11,2192,2111][i]?.getD 0
  accumulator := fun i => #[11,11,2192,2330][i]?.getD 0
theorem rotationDot_15_3_checked : rotationDot_15_3.ExtendedCheck nodes 3 := by decide
def rotationDot_15_4 : DotRecipe where
  left := fun i => #[11,14,265][i]?.getD 0
  right := fun i => #[14,11,15][i]?.getD 0
  product := fun i => #[11,11,2114][i]?.getD 0
  accumulator := fun i => #[11,11,11,2114][i]?.getD 0
theorem rotationDot_15_4_checked : rotationDot_15_4.ExtendedCheck nodes 3 := by decide
def rotationDot_15_5 : DotRecipe where
  left := fun i => #[11,14,265][i]?.getD 0
  right := fun i => #[16,111,11][i]?.getD 0
  product := fun i => #[11,2197,11][i]?.getD 0
  accumulator := fun i => #[11,11,2197,2197][i]?.getD 0
theorem rotationDot_15_5_checked : rotationDot_15_5.ExtendedCheck nodes 3 := by decide
def rotationDot_15_6 : DotRecipe where
  left := fun i => #[11,14,265][i]?.getD 0
  right := fun i => #[11,5,265][i]?.getD 0
  product := fun i => #[11,2192,266][i]?.getD 0
  accumulator := fun i => #[11,11,2192,2334][i]?.getD 0
theorem rotationDot_15_6_checked : rotationDot_15_6.ExtendedCheck nodes 3 := by decide
def rotationDot_15_7 : DotRecipe where
  left := fun i => #[11,14,265][i]?.getD 0
  right := fun i => #[14,11,15][i]?.getD 0
  product := fun i => #[11,11,2114][i]?.getD 0
  accumulator := fun i => #[11,11,11,2114][i]?.getD 0
theorem rotationDot_15_7_checked : rotationDot_15_7.ExtendedCheck nodes 3 := by decide
def rotationDot_15_8 : DotRecipe where
  left := fun i => #[11,14,265][i]?.getD 0
  right := fun i => #[17,111,11][i]?.getD 0
  product := fun i => #[11,2197,11][i]?.getD 0
  accumulator := fun i => #[11,11,2197,2197][i]?.getD 0
theorem rotationDot_15_8_checked : rotationDot_15_8.ExtendedCheck nodes 3 := by decide
def rotationDot_15_9 : DotRecipe where
  left := fun i => #[11,14,265][i]?.getD 0
  right := fun i => #[11,14,11][i]?.getD 0
  product := fun i => #[11,822,11][i]?.getD 0
  accumulator := fun i => #[11,11,822,822][i]?.getD 0
theorem rotationDot_15_9_checked : rotationDot_15_9.ExtendedCheck nodes 3 := by decide
def rotationDot_15_10 : DotRecipe where
  left := fun i => #[11,14,265][i]?.getD 0
  right := fun i => #[488,11,0][i]?.getD 0
  product := fun i => #[11,11,2108][i]?.getD 0
  accumulator := fun i => #[11,11,11,2108][i]?.getD 0
theorem rotationDot_15_10_checked : rotationDot_15_10.ExtendedCheck nodes 3 := by decide
def rotationDot_15_11 : DotRecipe where
  left := fun i => #[11,14,265][i]?.getD 0
  right := fun i => #[11,20,11][i]?.getD 0
  product := fun i => #[11,2194,11][i]?.getD 0
  accumulator := fun i => #[11,11,2194,2194][i]?.getD 0
theorem rotationDot_15_11_checked : rotationDot_15_11.ExtendedCheck nodes 3 := by decide
def rotationDot_15_12 : DotRecipe where
  left := fun i => #[11,14,265][i]?.getD 0
  right := fun i => #[11,14,113][i]?.getD 0
  product := fun i => #[11,822,2111][i]?.getD 0
  accumulator := fun i => #[11,11,822,2339][i]?.getD 0
theorem rotationDot_15_12_checked : rotationDot_15_12.ExtendedCheck nodes 3 := by decide
def rotationDot_15_13 : DotRecipe where
  left := fun i => #[11,14,265][i]?.getD 0
  right := fun i => #[488,11,15][i]?.getD 0
  product := fun i => #[11,11,2114][i]?.getD 0
  accumulator := fun i => #[11,11,11,2114][i]?.getD 0
theorem rotationDot_15_13_checked : rotationDot_15_13.ExtendedCheck nodes 3 := by decide
def rotationDot_15_14 : DotRecipe where
  left := fun i => #[11,14,265][i]?.getD 0
  right := fun i => #[16,111,11][i]?.getD 0
  product := fun i => #[11,2197,11][i]?.getD 0
  accumulator := fun i => #[11,11,2197,2197][i]?.getD 0
theorem rotationDot_15_14_checked : rotationDot_15_14.ExtendedCheck nodes 3 := by decide
def rotationDot_15_15 : DotRecipe where
  left := fun i => #[11,14,265][i]?.getD 0
  right := fun i => #[11,14,265][i]?.getD 0
  product := fun i => #[11,822,266][i]?.getD 0
  accumulator := fun i => #[11,11,822,2342][i]?.getD 0
theorem rotationDot_15_15_checked : rotationDot_15_15.ExtendedCheck nodes 3 := by decide
def rotationDot_15_16 : DotRecipe where
  left := fun i => #[11,14,265][i]?.getD 0
  right := fun i => #[488,11,15][i]?.getD 0
  product := fun i => #[11,11,2114][i]?.getD 0
  accumulator := fun i => #[11,11,11,2114][i]?.getD 0
theorem rotationDot_15_16_checked : rotationDot_15_16.ExtendedCheck nodes 3 := by decide
def rotationDot_15_17 : DotRecipe where
  left := fun i => #[11,14,265][i]?.getD 0
  right := fun i => #[17,111,11][i]?.getD 0
  product := fun i => #[11,2197,11][i]?.getD 0
  accumulator := fun i => #[11,11,2197,2197][i]?.getD 0
theorem rotationDot_15_17_checked : rotationDot_15_17.ExtendedCheck nodes 3 := by decide
def rotationDot_15_18 : DotRecipe where
  left := fun i => #[11,14,265][i]?.getD 0
  right := fun i => #[11,11,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_15_18_checked : rotationDot_15_18.ExtendedCheck nodes 3 := by decide
def rotationDot_15_19 : DotRecipe where
  left := fun i => #[11,14,265][i]?.getD 0
  right := fun i => #[11,11,18][i]?.getD 0
  product := fun i => #[11,11,2131][i]?.getD 0
  accumulator := fun i => #[11,11,11,2131][i]?.getD 0
theorem rotationDot_15_19_checked : rotationDot_15_19.ExtendedCheck nodes 3 := by decide
def rotationDot_15_20 : DotRecipe where
  left := fun i => #[11,14,265][i]?.getD 0
  right := fun i => #[11,2,11][i]?.getD 0
  product := fun i => #[11,14,11][i]?.getD 0
  accumulator := fun i => #[11,11,14,14][i]?.getD 0
theorem rotationDot_15_20_checked : rotationDot_15_20.ExtendedCheck nodes 3 := by decide
def rotationDot_15_21 : DotRecipe where
  left := fun i => #[11,14,265][i]?.getD 0
  right := fun i => #[11,11,19][i]?.getD 0
  product := fun i => #[11,11,2134][i]?.getD 0
  accumulator := fun i => #[11,11,11,2134][i]?.getD 0
theorem rotationDot_15_21_checked : rotationDot_15_21.ExtendedCheck nodes 3 := by decide
def rotationDot_15_22 : DotRecipe where
  left := fun i => #[11,14,265][i]?.getD 0
  right := fun i => #[11,11,9][i]?.getD 0
  product := fun i => #[11,11,2136][i]?.getD 0
  accumulator := fun i => #[11,11,11,2136][i]?.getD 0
theorem rotationDot_15_22_checked : rotationDot_15_22.ExtendedCheck nodes 3 := by decide
def rotationDot_15_23 : DotRecipe where
  left := fun i => #[11,14,265][i]?.getD 0
  right := fun i => #[13,12,11][i]?.getD 0
  product := fun i => #[11,2208,11][i]?.getD 0
  accumulator := fun i => #[11,11,2208,2208][i]?.getD 0
theorem rotationDot_15_23_checked : rotationDot_15_23.ExtendedCheck nodes 3 := by decide
def rotationDot_15_24 : DotRecipe where
  left := fun i => #[11,14,265][i]?.getD 0
  right := fun i => #[11,11,1926][i]?.getD 0
  product := fun i => #[11,11,2139][i]?.getD 0
  accumulator := fun i => #[11,11,11,2139][i]?.getD 0
theorem rotationDot_15_24_checked : rotationDot_15_24.ExtendedCheck nodes 3 := by decide
def rotationDot_15_25 : DotRecipe where
  left := fun i => #[11,14,265][i]?.getD 0
  right := fun i => #[11,11,9][i]?.getD 0
  product := fun i => #[11,11,2136][i]?.getD 0
  accumulator := fun i => #[11,11,11,2136][i]?.getD 0
theorem rotationDot_15_25_checked : rotationDot_15_25.ExtendedCheck nodes 3 := by decide
def rotationDot_15_26 : DotRecipe where
  left := fun i => #[11,14,265][i]?.getD 0
  right := fun i => #[19,12,11][i]?.getD 0
  product := fun i => #[11,2208,11][i]?.getD 0
  accumulator := fun i => #[11,11,2208,2208][i]?.getD 0
theorem rotationDot_15_26_checked : rotationDot_15_26.ExtendedCheck nodes 3 := by decide
def rotationDotsRow15 : Array DotRecipe := #[rotationDot_15_0,rotationDot_15_1,rotationDot_15_2,rotationDot_15_3,rotationDot_15_4,rotationDot_15_5,rotationDot_15_6,rotationDot_15_7,rotationDot_15_8,rotationDot_15_9,rotationDot_15_10,rotationDot_15_11,rotationDot_15_12,rotationDot_15_13,rotationDot_15_14,rotationDot_15_15,rotationDot_15_16,rotationDot_15_17,rotationDot_15_18,rotationDot_15_19,rotationDot_15_20,rotationDot_15_21,rotationDot_15_22,rotationDot_15_23,rotationDot_15_24,rotationDot_15_25,rotationDot_15_26]
theorem rotationDotsRow15_checked (j : Fin 27) :
    (rotationDotsRow15[j.val]?.getD rotationDot_0_0).ExtendedCheck nodes 3 := by
  fin_cases j
  · exact rotationDot_15_0_checked
  · exact rotationDot_15_1_checked
  · exact rotationDot_15_2_checked
  · exact rotationDot_15_3_checked
  · exact rotationDot_15_4_checked
  · exact rotationDot_15_5_checked
  · exact rotationDot_15_6_checked
  · exact rotationDot_15_7_checked
  · exact rotationDot_15_8_checked
  · exact rotationDot_15_9_checked
  · exact rotationDot_15_10_checked
  · exact rotationDot_15_11_checked
  · exact rotationDot_15_12_checked
  · exact rotationDot_15_13_checked
  · exact rotationDot_15_14_checked
  · exact rotationDot_15_15_checked
  · exact rotationDot_15_16_checked
  · exact rotationDot_15_17_checked
  · exact rotationDot_15_18_checked
  · exact rotationDot_15_19_checked
  · exact rotationDot_15_20_checked
  · exact rotationDot_15_21_checked
  · exact rotationDot_15_22_checked
  · exact rotationDot_15_23_checked
  · exact rotationDot_15_24_checked
  · exact rotationDot_15_25_checked
  · exact rotationDot_15_26_checked
def rotationDot_16_0 : DotRecipe where
  left := fun i => #[488,11,15][i]?.getD 0
  right := fun i => #[11,5,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_16_0_checked : rotationDot_16_0.ExtendedCheck nodes 3 := by decide
def rotationDot_16_1 : DotRecipe where
  left := fun i => #[488,11,15][i]?.getD 0
  right := fun i => #[14,11,0][i]?.getD 0
  product := fun i => #[2211,11,2040][i]?.getD 0
  accumulator := fun i => #[11,2211,2211,2283][i]?.getD 0
theorem rotationDot_16_1_checked : rotationDot_16_1.ExtendedCheck nodes 3 := by decide
def rotationDot_16_2 : DotRecipe where
  left := fun i => #[488,11,15][i]?.getD 0
  right := fun i => #[11,20,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_16_2_checked : rotationDot_16_2.ExtendedCheck nodes 3 := by decide
def rotationDot_16_3 : DotRecipe where
  left := fun i => #[488,11,15][i]?.getD 0
  right := fun i => #[11,5,113][i]?.getD 0
  product := fun i => #[11,11,2043][i]?.getD 0
  accumulator := fun i => #[11,11,11,2043][i]?.getD 0
theorem rotationDot_16_3_checked : rotationDot_16_3.ExtendedCheck nodes 3 := by decide
def rotationDot_16_4 : DotRecipe where
  left := fun i => #[488,11,15][i]?.getD 0
  right := fun i => #[14,11,15][i]?.getD 0
  product := fun i => #[2211,11,2045][i]?.getD 0
  accumulator := fun i => #[11,2211,2211,2285][i]?.getD 0
theorem rotationDot_16_4_checked : rotationDot_16_4.ExtendedCheck nodes 3 := by decide
def rotationDot_16_5 : DotRecipe where
  left := fun i => #[488,11,15][i]?.getD 0
  right := fun i => #[16,111,11][i]?.getD 0
  product := fun i => #[2217,11,11][i]?.getD 0
  accumulator := fun i => #[11,2217,2217,2217][i]?.getD 0
theorem rotationDot_16_5_checked : rotationDot_16_5.ExtendedCheck nodes 3 := by decide
def rotationDot_16_6 : DotRecipe where
  left := fun i => #[488,11,15][i]?.getD 0
  right := fun i => #[11,5,265][i]?.getD 0
  product := fun i => #[11,11,2049][i]?.getD 0
  accumulator := fun i => #[11,11,11,2049][i]?.getD 0
theorem rotationDot_16_6_checked : rotationDot_16_6.ExtendedCheck nodes 3 := by decide
def rotationDot_16_7 : DotRecipe where
  left := fun i => #[488,11,15][i]?.getD 0
  right := fun i => #[14,11,15][i]?.getD 0
  product := fun i => #[2211,11,2045][i]?.getD 0
  accumulator := fun i => #[11,2211,2211,2285][i]?.getD 0
theorem rotationDot_16_7_checked : rotationDot_16_7.ExtendedCheck nodes 3 := by decide
def rotationDot_16_8 : DotRecipe where
  left := fun i => #[488,11,15][i]?.getD 0
  right := fun i => #[17,111,11][i]?.getD 0
  product := fun i => #[2221,11,11][i]?.getD 0
  accumulator := fun i => #[11,2221,2221,2221][i]?.getD 0
theorem rotationDot_16_8_checked : rotationDot_16_8.ExtendedCheck nodes 3 := by decide
def rotationDot_16_9 : DotRecipe where
  left := fun i => #[488,11,15][i]?.getD 0
  right := fun i => #[11,14,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_16_9_checked : rotationDot_16_9.ExtendedCheck nodes 3 := by decide
def rotationDot_16_10 : DotRecipe where
  left := fun i => #[488,11,15][i]?.getD 0
  right := fun i => #[488,11,0][i]?.getD 0
  product := fun i => #[966,11,2040][i]?.getD 0
  accumulator := fun i => #[11,966,966,2291][i]?.getD 0
theorem rotationDot_16_10_checked : rotationDot_16_10.ExtendedCheck nodes 3 := by decide
def rotationDot_16_11 : DotRecipe where
  left := fun i => #[488,11,15][i]?.getD 0
  right := fun i => #[11,20,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_16_11_checked : rotationDot_16_11.ExtendedCheck nodes 3 := by decide
def rotationDot_16_12 : DotRecipe where
  left := fun i => #[488,11,15][i]?.getD 0
  right := fun i => #[11,14,113][i]?.getD 0
  product := fun i => #[11,11,2043][i]?.getD 0
  accumulator := fun i => #[11,11,11,2043][i]?.getD 0
theorem rotationDot_16_12_checked : rotationDot_16_12.ExtendedCheck nodes 3 := by decide
def rotationDot_16_13 : DotRecipe where
  left := fun i => #[488,11,15][i]?.getD 0
  right := fun i => #[488,11,15][i]?.getD 0
  product := fun i => #[966,11,2045][i]?.getD 0
  accumulator := fun i => #[11,966,966,2294][i]?.getD 0
theorem rotationDot_16_13_checked : rotationDot_16_13.ExtendedCheck nodes 3 := by decide
def rotationDot_16_14 : DotRecipe where
  left := fun i => #[488,11,15][i]?.getD 0
  right := fun i => #[16,111,11][i]?.getD 0
  product := fun i => #[2217,11,11][i]?.getD 0
  accumulator := fun i => #[11,2217,2217,2217][i]?.getD 0
theorem rotationDot_16_14_checked : rotationDot_16_14.ExtendedCheck nodes 3 := by decide
def rotationDot_16_15 : DotRecipe where
  left := fun i => #[488,11,15][i]?.getD 0
  right := fun i => #[11,14,265][i]?.getD 0
  product := fun i => #[11,11,2049][i]?.getD 0
  accumulator := fun i => #[11,11,11,2049][i]?.getD 0
theorem rotationDot_16_15_checked : rotationDot_16_15.ExtendedCheck nodes 3 := by decide
def rotationDot_16_16 : DotRecipe where
  left := fun i => #[488,11,15][i]?.getD 0
  right := fun i => #[488,11,15][i]?.getD 0
  product := fun i => #[966,11,2045][i]?.getD 0
  accumulator := fun i => #[11,966,966,2294][i]?.getD 0
theorem rotationDot_16_16_checked : rotationDot_16_16.ExtendedCheck nodes 3 := by decide
def rotationDot_16_17 : DotRecipe where
  left := fun i => #[488,11,15][i]?.getD 0
  right := fun i => #[17,111,11][i]?.getD 0
  product := fun i => #[2221,11,11][i]?.getD 0
  accumulator := fun i => #[11,2221,2221,2221][i]?.getD 0
theorem rotationDot_16_17_checked : rotationDot_16_17.ExtendedCheck nodes 3 := by decide
def rotationDot_16_18 : DotRecipe where
  left := fun i => #[488,11,15][i]?.getD 0
  right := fun i => #[11,11,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_16_18_checked : rotationDot_16_18.ExtendedCheck nodes 3 := by decide
def rotationDot_16_19 : DotRecipe where
  left := fun i => #[488,11,15][i]?.getD 0
  right := fun i => #[11,11,18][i]?.getD 0
  product := fun i => #[11,11,2062][i]?.getD 0
  accumulator := fun i => #[11,11,11,2062][i]?.getD 0
theorem rotationDot_16_19_checked : rotationDot_16_19.ExtendedCheck nodes 3 := by decide
def rotationDot_16_20 : DotRecipe where
  left := fun i => #[488,11,15][i]?.getD 0
  right := fun i => #[11,2,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_16_20_checked : rotationDot_16_20.ExtendedCheck nodes 3 := by decide
def rotationDot_16_21 : DotRecipe where
  left := fun i => #[488,11,15][i]?.getD 0
  right := fun i => #[11,11,19][i]?.getD 0
  product := fun i => #[11,11,2064][i]?.getD 0
  accumulator := fun i => #[11,11,11,2064][i]?.getD 0
theorem rotationDot_16_21_checked : rotationDot_16_21.ExtendedCheck nodes 3 := by decide
def rotationDot_16_22 : DotRecipe where
  left := fun i => #[488,11,15][i]?.getD 0
  right := fun i => #[11,11,9][i]?.getD 0
  product := fun i => #[11,11,2066][i]?.getD 0
  accumulator := fun i => #[11,11,11,2066][i]?.getD 0
theorem rotationDot_16_22_checked : rotationDot_16_22.ExtendedCheck nodes 3 := by decide
def rotationDot_16_23 : DotRecipe where
  left := fun i => #[488,11,15][i]?.getD 0
  right := fun i => #[13,12,11][i]?.getD 0
  product := fun i => #[2235,11,11][i]?.getD 0
  accumulator := fun i => #[11,2235,2235,2235][i]?.getD 0
theorem rotationDot_16_23_checked : rotationDot_16_23.ExtendedCheck nodes 3 := by decide
def rotationDot_16_24 : DotRecipe where
  left := fun i => #[488,11,15][i]?.getD 0
  right := fun i => #[11,11,1926][i]?.getD 0
  product := fun i => #[11,11,2069][i]?.getD 0
  accumulator := fun i => #[11,11,11,2069][i]?.getD 0
theorem rotationDot_16_24_checked : rotationDot_16_24.ExtendedCheck nodes 3 := by decide
def rotationDot_16_25 : DotRecipe where
  left := fun i => #[488,11,15][i]?.getD 0
  right := fun i => #[11,11,9][i]?.getD 0
  product := fun i => #[11,11,2066][i]?.getD 0
  accumulator := fun i => #[11,11,11,2066][i]?.getD 0
theorem rotationDot_16_25_checked : rotationDot_16_25.ExtendedCheck nodes 3 := by decide
def rotationDot_16_26 : DotRecipe where
  left := fun i => #[488,11,15][i]?.getD 0
  right := fun i => #[19,12,11][i]?.getD 0
  product := fun i => #[2239,11,11][i]?.getD 0
  accumulator := fun i => #[11,2239,2239,2239][i]?.getD 0
theorem rotationDot_16_26_checked : rotationDot_16_26.ExtendedCheck nodes 3 := by decide
def rotationDotsRow16 : Array DotRecipe := #[rotationDot_16_0,rotationDot_16_1,rotationDot_16_2,rotationDot_16_3,rotationDot_16_4,rotationDot_16_5,rotationDot_16_6,rotationDot_16_7,rotationDot_16_8,rotationDot_16_9,rotationDot_16_10,rotationDot_16_11,rotationDot_16_12,rotationDot_16_13,rotationDot_16_14,rotationDot_16_15,rotationDot_16_16,rotationDot_16_17,rotationDot_16_18,rotationDot_16_19,rotationDot_16_20,rotationDot_16_21,rotationDot_16_22,rotationDot_16_23,rotationDot_16_24,rotationDot_16_25,rotationDot_16_26]
theorem rotationDotsRow16_checked (j : Fin 27) :
    (rotationDotsRow16[j.val]?.getD rotationDot_0_0).ExtendedCheck nodes 3 := by
  fin_cases j
  · exact rotationDot_16_0_checked
  · exact rotationDot_16_1_checked
  · exact rotationDot_16_2_checked
  · exact rotationDot_16_3_checked
  · exact rotationDot_16_4_checked
  · exact rotationDot_16_5_checked
  · exact rotationDot_16_6_checked
  · exact rotationDot_16_7_checked
  · exact rotationDot_16_8_checked
  · exact rotationDot_16_9_checked
  · exact rotationDot_16_10_checked
  · exact rotationDot_16_11_checked
  · exact rotationDot_16_12_checked
  · exact rotationDot_16_13_checked
  · exact rotationDot_16_14_checked
  · exact rotationDot_16_15_checked
  · exact rotationDot_16_16_checked
  · exact rotationDot_16_17_checked
  · exact rotationDot_16_18_checked
  · exact rotationDot_16_19_checked
  · exact rotationDot_16_20_checked
  · exact rotationDot_16_21_checked
  · exact rotationDot_16_22_checked
  · exact rotationDot_16_23_checked
  · exact rotationDot_16_24_checked
  · exact rotationDot_16_25_checked
  · exact rotationDot_16_26_checked
def rotationDot_17_0 : DotRecipe where
  left := fun i => #[17,111,11][i]?.getD 0
  right := fun i => #[11,5,11][i]?.getD 0
  product := fun i => #[11,2073,11][i]?.getD 0
  accumulator := fun i => #[11,11,2073,2073][i]?.getD 0
theorem rotationDot_17_0_checked : rotationDot_17_0.ExtendedCheck nodes 3 := by decide
def rotationDot_17_1 : DotRecipe where
  left := fun i => #[17,111,11][i]?.getD 0
  right := fun i => #[14,11,0][i]?.getD 0
  product := fun i => #[2164,11,11][i]?.getD 0
  accumulator := fun i => #[11,2164,2164,2164][i]?.getD 0
theorem rotationDot_17_1_checked : rotationDot_17_1.ExtendedCheck nodes 3 := by decide
def rotationDot_17_2 : DotRecipe where
  left := fun i => #[17,111,11][i]?.getD 0
  right := fun i => #[11,20,11][i]?.getD 0
  product := fun i => #[11,2077,11][i]?.getD 0
  accumulator := fun i => #[11,11,2077,2077][i]?.getD 0
theorem rotationDot_17_2_checked : rotationDot_17_2.ExtendedCheck nodes 3 := by decide
def rotationDot_17_3 : DotRecipe where
  left := fun i => #[17,111,11][i]?.getD 0
  right := fun i => #[11,5,113][i]?.getD 0
  product := fun i => #[11,2073,11][i]?.getD 0
  accumulator := fun i => #[11,11,2073,2073][i]?.getD 0
theorem rotationDot_17_3_checked : rotationDot_17_3.ExtendedCheck nodes 3 := by decide
def rotationDot_17_4 : DotRecipe where
  left := fun i => #[17,111,11][i]?.getD 0
  right := fun i => #[14,11,15][i]?.getD 0
  product := fun i => #[2164,11,11][i]?.getD 0
  accumulator := fun i => #[11,2164,2164,2164][i]?.getD 0
theorem rotationDot_17_4_checked : rotationDot_17_4.ExtendedCheck nodes 3 := by decide
def rotationDot_17_5 : DotRecipe where
  left := fun i => #[17,111,11][i]?.getD 0
  right := fun i => #[16,111,11][i]?.getD 0
  product := fun i => #[2168,2081,11][i]?.getD 0
  accumulator := fun i => #[11,2168,2169,2169][i]?.getD 0
theorem rotationDot_17_5_checked : rotationDot_17_5.ExtendedCheck nodes 3 := by decide
def rotationDot_17_6 : DotRecipe where
  left := fun i => #[17,111,11][i]?.getD 0
  right := fun i => #[11,5,265][i]?.getD 0
  product := fun i => #[11,2073,11][i]?.getD 0
  accumulator := fun i => #[11,11,2073,2073][i]?.getD 0
theorem rotationDot_17_6_checked : rotationDot_17_6.ExtendedCheck nodes 3 := by decide
def rotationDot_17_7 : DotRecipe where
  left := fun i => #[17,111,11][i]?.getD 0
  right := fun i => #[14,11,15][i]?.getD 0
  product := fun i => #[2164,11,11][i]?.getD 0
  accumulator := fun i => #[11,2164,2164,2164][i]?.getD 0
theorem rotationDot_17_7_checked : rotationDot_17_7.ExtendedCheck nodes 3 := by decide
def rotationDot_17_8 : DotRecipe where
  left := fun i => #[17,111,11][i]?.getD 0
  right := fun i => #[17,111,11][i]?.getD 0
  product := fun i => #[63,2081,11][i]?.getD 0
  accumulator := fun i => #[11,63,2173,2173][i]?.getD 0
theorem rotationDot_17_8_checked : rotationDot_17_8.ExtendedCheck nodes 3 := by decide
def rotationDot_17_9 : DotRecipe where
  left := fun i => #[17,111,11][i]?.getD 0
  right := fun i => #[11,14,11][i]?.getD 0
  product := fun i => #[11,2089,11][i]?.getD 0
  accumulator := fun i => #[11,11,2089,2089][i]?.getD 0
theorem rotationDot_17_9_checked : rotationDot_17_9.ExtendedCheck nodes 3 := by decide
def rotationDot_17_10 : DotRecipe where
  left := fun i => #[17,111,11][i]?.getD 0
  right := fun i => #[488,11,0][i]?.getD 0
  product := fun i => #[2176,11,11][i]?.getD 0
  accumulator := fun i => #[11,2176,2176,2176][i]?.getD 0
theorem rotationDot_17_10_checked : rotationDot_17_10.ExtendedCheck nodes 3 := by decide
def rotationDot_17_11 : DotRecipe where
  left := fun i => #[17,111,11][i]?.getD 0
  right := fun i => #[11,20,11][i]?.getD 0
  product := fun i => #[11,2077,11][i]?.getD 0
  accumulator := fun i => #[11,11,2077,2077][i]?.getD 0
theorem rotationDot_17_11_checked : rotationDot_17_11.ExtendedCheck nodes 3 := by decide
def rotationDot_17_12 : DotRecipe where
  left := fun i => #[17,111,11][i]?.getD 0
  right := fun i => #[11,14,113][i]?.getD 0
  product := fun i => #[11,2089,11][i]?.getD 0
  accumulator := fun i => #[11,11,2089,2089][i]?.getD 0
theorem rotationDot_17_12_checked : rotationDot_17_12.ExtendedCheck nodes 3 := by decide
def rotationDot_17_13 : DotRecipe where
  left := fun i => #[17,111,11][i]?.getD 0
  right := fun i => #[488,11,15][i]?.getD 0
  product := fun i => #[2176,11,11][i]?.getD 0
  accumulator := fun i => #[11,2176,2176,2176][i]?.getD 0
theorem rotationDot_17_13_checked : rotationDot_17_13.ExtendedCheck nodes 3 := by decide
def rotationDot_17_14 : DotRecipe where
  left := fun i => #[17,111,11][i]?.getD 0
  right := fun i => #[16,111,11][i]?.getD 0
  product := fun i => #[2168,2081,11][i]?.getD 0
  accumulator := fun i => #[11,2168,2169,2169][i]?.getD 0
theorem rotationDot_17_14_checked : rotationDot_17_14.ExtendedCheck nodes 3 := by decide
def rotationDot_17_15 : DotRecipe where
  left := fun i => #[17,111,11][i]?.getD 0
  right := fun i => #[11,14,265][i]?.getD 0
  product := fun i => #[11,2089,11][i]?.getD 0
  accumulator := fun i => #[11,11,2089,2089][i]?.getD 0
theorem rotationDot_17_15_checked : rotationDot_17_15.ExtendedCheck nodes 3 := by decide
def rotationDot_17_16 : DotRecipe where
  left := fun i => #[17,111,11][i]?.getD 0
  right := fun i => #[488,11,15][i]?.getD 0
  product := fun i => #[2176,11,11][i]?.getD 0
  accumulator := fun i => #[11,2176,2176,2176][i]?.getD 0
theorem rotationDot_17_16_checked : rotationDot_17_16.ExtendedCheck nodes 3 := by decide
def rotationDot_17_17 : DotRecipe where
  left := fun i => #[17,111,11][i]?.getD 0
  right := fun i => #[17,111,11][i]?.getD 0
  product := fun i => #[63,2081,11][i]?.getD 0
  accumulator := fun i => #[11,63,2173,2173][i]?.getD 0
theorem rotationDot_17_17_checked : rotationDot_17_17.ExtendedCheck nodes 3 := by decide
def rotationDot_17_18 : DotRecipe where
  left := fun i => #[17,111,11][i]?.getD 0
  right := fun i => #[11,11,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_17_18_checked : rotationDot_17_18.ExtendedCheck nodes 3 := by decide
def rotationDot_17_19 : DotRecipe where
  left := fun i => #[17,111,11][i]?.getD 0
  right := fun i => #[11,11,18][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_17_19_checked : rotationDot_17_19.ExtendedCheck nodes 3 := by decide
def rotationDot_17_20 : DotRecipe where
  left := fun i => #[17,111,11][i]?.getD 0
  right := fun i => #[11,2,11][i]?.getD 0
  product := fun i => #[11,111,11][i]?.getD 0
  accumulator := fun i => #[11,11,111,111][i]?.getD 0
theorem rotationDot_17_20_checked : rotationDot_17_20.ExtendedCheck nodes 3 := by decide
def rotationDot_17_21 : DotRecipe where
  left := fun i => #[17,111,11][i]?.getD 0
  right := fun i => #[11,11,19][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_17_21_checked : rotationDot_17_21.ExtendedCheck nodes 3 := by decide
def rotationDot_17_22 : DotRecipe where
  left := fun i => #[17,111,11][i]?.getD 0
  right := fun i => #[11,11,9][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_17_22_checked : rotationDot_17_22.ExtendedCheck nodes 3 := by decide
def rotationDot_17_23 : DotRecipe where
  left := fun i => #[17,111,11][i]?.getD 0
  right := fun i => #[13,12,11][i]?.getD 0
  product := fun i => #[2186,2102,11][i]?.getD 0
  accumulator := fun i => #[11,2186,2187,2187][i]?.getD 0
theorem rotationDot_17_23_checked : rotationDot_17_23.ExtendedCheck nodes 3 := by decide
def rotationDot_17_24 : DotRecipe where
  left := fun i => #[17,111,11][i]?.getD 0
  right := fun i => #[11,11,1926][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_17_24_checked : rotationDot_17_24.ExtendedCheck nodes 3 := by decide
def rotationDot_17_25 : DotRecipe where
  left := fun i => #[17,111,11][i]?.getD 0
  right := fun i => #[11,11,9][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_17_25_checked : rotationDot_17_25.ExtendedCheck nodes 3 := by decide
def rotationDot_17_26 : DotRecipe where
  left := fun i => #[17,111,11][i]?.getD 0
  right := fun i => #[19,12,11][i]?.getD 0
  product := fun i => #[2189,2102,11][i]?.getD 0
  accumulator := fun i => #[11,2189,2190,2190][i]?.getD 0
theorem rotationDot_17_26_checked : rotationDot_17_26.ExtendedCheck nodes 3 := by decide
def rotationDotsRow17 : Array DotRecipe := #[rotationDot_17_0,rotationDot_17_1,rotationDot_17_2,rotationDot_17_3,rotationDot_17_4,rotationDot_17_5,rotationDot_17_6,rotationDot_17_7,rotationDot_17_8,rotationDot_17_9,rotationDot_17_10,rotationDot_17_11,rotationDot_17_12,rotationDot_17_13,rotationDot_17_14,rotationDot_17_15,rotationDot_17_16,rotationDot_17_17,rotationDot_17_18,rotationDot_17_19,rotationDot_17_20,rotationDot_17_21,rotationDot_17_22,rotationDot_17_23,rotationDot_17_24,rotationDot_17_25,rotationDot_17_26]
theorem rotationDotsRow17_checked (j : Fin 27) :
    (rotationDotsRow17[j.val]?.getD rotationDot_0_0).ExtendedCheck nodes 3 := by
  fin_cases j
  · exact rotationDot_17_0_checked
  · exact rotationDot_17_1_checked
  · exact rotationDot_17_2_checked
  · exact rotationDot_17_3_checked
  · exact rotationDot_17_4_checked
  · exact rotationDot_17_5_checked
  · exact rotationDot_17_6_checked
  · exact rotationDot_17_7_checked
  · exact rotationDot_17_8_checked
  · exact rotationDot_17_9_checked
  · exact rotationDot_17_10_checked
  · exact rotationDot_17_11_checked
  · exact rotationDot_17_12_checked
  · exact rotationDot_17_13_checked
  · exact rotationDot_17_14_checked
  · exact rotationDot_17_15_checked
  · exact rotationDot_17_16_checked
  · exact rotationDot_17_17_checked
  · exact rotationDot_17_18_checked
  · exact rotationDot_17_19_checked
  · exact rotationDot_17_20_checked
  · exact rotationDot_17_21_checked
  · exact rotationDot_17_22_checked
  · exact rotationDot_17_23_checked
  · exact rotationDot_17_24_checked
  · exact rotationDot_17_25_checked
  · exact rotationDot_17_26_checked
def rotationDot_18_0 : DotRecipe where
  left := fun i => #[11,11,11][i]?.getD 0
  right := fun i => #[11,5,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_18_0_checked : rotationDot_18_0.ExtendedCheck nodes 3 := by decide
def rotationDot_18_1 : DotRecipe where
  left := fun i => #[11,11,11][i]?.getD 0
  right := fun i => #[14,11,0][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_18_1_checked : rotationDot_18_1.ExtendedCheck nodes 3 := by decide
def rotationDot_18_2 : DotRecipe where
  left := fun i => #[11,11,11][i]?.getD 0
  right := fun i => #[11,20,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_18_2_checked : rotationDot_18_2.ExtendedCheck nodes 3 := by decide
def rotationDot_18_3 : DotRecipe where
  left := fun i => #[11,11,11][i]?.getD 0
  right := fun i => #[11,5,113][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_18_3_checked : rotationDot_18_3.ExtendedCheck nodes 3 := by decide
def rotationDot_18_4 : DotRecipe where
  left := fun i => #[11,11,11][i]?.getD 0
  right := fun i => #[14,11,15][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_18_4_checked : rotationDot_18_4.ExtendedCheck nodes 3 := by decide
def rotationDot_18_5 : DotRecipe where
  left := fun i => #[11,11,11][i]?.getD 0
  right := fun i => #[16,111,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_18_5_checked : rotationDot_18_5.ExtendedCheck nodes 3 := by decide
def rotationDot_18_6 : DotRecipe where
  left := fun i => #[11,11,11][i]?.getD 0
  right := fun i => #[11,5,265][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_18_6_checked : rotationDot_18_6.ExtendedCheck nodes 3 := by decide
def rotationDot_18_7 : DotRecipe where
  left := fun i => #[11,11,11][i]?.getD 0
  right := fun i => #[14,11,15][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_18_7_checked : rotationDot_18_7.ExtendedCheck nodes 3 := by decide
def rotationDot_18_8 : DotRecipe where
  left := fun i => #[11,11,11][i]?.getD 0
  right := fun i => #[17,111,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_18_8_checked : rotationDot_18_8.ExtendedCheck nodes 3 := by decide
def rotationDot_18_9 : DotRecipe where
  left := fun i => #[11,11,11][i]?.getD 0
  right := fun i => #[11,14,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_18_9_checked : rotationDot_18_9.ExtendedCheck nodes 3 := by decide
def rotationDot_18_10 : DotRecipe where
  left := fun i => #[11,11,11][i]?.getD 0
  right := fun i => #[488,11,0][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_18_10_checked : rotationDot_18_10.ExtendedCheck nodes 3 := by decide
def rotationDot_18_11 : DotRecipe where
  left := fun i => #[11,11,11][i]?.getD 0
  right := fun i => #[11,20,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_18_11_checked : rotationDot_18_11.ExtendedCheck nodes 3 := by decide
def rotationDot_18_12 : DotRecipe where
  left := fun i => #[11,11,11][i]?.getD 0
  right := fun i => #[11,14,113][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_18_12_checked : rotationDot_18_12.ExtendedCheck nodes 3 := by decide
def rotationDot_18_13 : DotRecipe where
  left := fun i => #[11,11,11][i]?.getD 0
  right := fun i => #[488,11,15][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_18_13_checked : rotationDot_18_13.ExtendedCheck nodes 3 := by decide
def rotationDot_18_14 : DotRecipe where
  left := fun i => #[11,11,11][i]?.getD 0
  right := fun i => #[16,111,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_18_14_checked : rotationDot_18_14.ExtendedCheck nodes 3 := by decide
def rotationDot_18_15 : DotRecipe where
  left := fun i => #[11,11,11][i]?.getD 0
  right := fun i => #[11,14,265][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_18_15_checked : rotationDot_18_15.ExtendedCheck nodes 3 := by decide
def rotationDot_18_16 : DotRecipe where
  left := fun i => #[11,11,11][i]?.getD 0
  right := fun i => #[488,11,15][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_18_16_checked : rotationDot_18_16.ExtendedCheck nodes 3 := by decide
def rotationDot_18_17 : DotRecipe where
  left := fun i => #[11,11,11][i]?.getD 0
  right := fun i => #[17,111,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_18_17_checked : rotationDot_18_17.ExtendedCheck nodes 3 := by decide
def rotationDot_18_18 : DotRecipe where
  left := fun i => #[11,11,11][i]?.getD 0
  right := fun i => #[11,11,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_18_18_checked : rotationDot_18_18.ExtendedCheck nodes 3 := by decide
def rotationDot_18_19 : DotRecipe where
  left := fun i => #[11,11,11][i]?.getD 0
  right := fun i => #[11,11,18][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_18_19_checked : rotationDot_18_19.ExtendedCheck nodes 3 := by decide
def rotationDot_18_20 : DotRecipe where
  left := fun i => #[11,11,11][i]?.getD 0
  right := fun i => #[11,2,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_18_20_checked : rotationDot_18_20.ExtendedCheck nodes 3 := by decide
def rotationDot_18_21 : DotRecipe where
  left := fun i => #[11,11,11][i]?.getD 0
  right := fun i => #[11,11,19][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_18_21_checked : rotationDot_18_21.ExtendedCheck nodes 3 := by decide
def rotationDot_18_22 : DotRecipe where
  left := fun i => #[11,11,11][i]?.getD 0
  right := fun i => #[11,11,9][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_18_22_checked : rotationDot_18_22.ExtendedCheck nodes 3 := by decide
def rotationDot_18_23 : DotRecipe where
  left := fun i => #[11,11,11][i]?.getD 0
  right := fun i => #[13,12,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_18_23_checked : rotationDot_18_23.ExtendedCheck nodes 3 := by decide
def rotationDot_18_24 : DotRecipe where
  left := fun i => #[11,11,11][i]?.getD 0
  right := fun i => #[11,11,1926][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_18_24_checked : rotationDot_18_24.ExtendedCheck nodes 3 := by decide
def rotationDot_18_25 : DotRecipe where
  left := fun i => #[11,11,11][i]?.getD 0
  right := fun i => #[11,11,9][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_18_25_checked : rotationDot_18_25.ExtendedCheck nodes 3 := by decide
def rotationDot_18_26 : DotRecipe where
  left := fun i => #[11,11,11][i]?.getD 0
  right := fun i => #[19,12,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_18_26_checked : rotationDot_18_26.ExtendedCheck nodes 3 := by decide
def rotationDotsRow18 : Array DotRecipe := #[rotationDot_18_0,rotationDot_18_1,rotationDot_18_2,rotationDot_18_3,rotationDot_18_4,rotationDot_18_5,rotationDot_18_6,rotationDot_18_7,rotationDot_18_8,rotationDot_18_9,rotationDot_18_10,rotationDot_18_11,rotationDot_18_12,rotationDot_18_13,rotationDot_18_14,rotationDot_18_15,rotationDot_18_16,rotationDot_18_17,rotationDot_18_18,rotationDot_18_19,rotationDot_18_20,rotationDot_18_21,rotationDot_18_22,rotationDot_18_23,rotationDot_18_24,rotationDot_18_25,rotationDot_18_26]
theorem rotationDotsRow18_checked (j : Fin 27) :
    (rotationDotsRow18[j.val]?.getD rotationDot_0_0).ExtendedCheck nodes 3 := by
  fin_cases j
  · exact rotationDot_18_0_checked
  · exact rotationDot_18_1_checked
  · exact rotationDot_18_2_checked
  · exact rotationDot_18_3_checked
  · exact rotationDot_18_4_checked
  · exact rotationDot_18_5_checked
  · exact rotationDot_18_6_checked
  · exact rotationDot_18_7_checked
  · exact rotationDot_18_8_checked
  · exact rotationDot_18_9_checked
  · exact rotationDot_18_10_checked
  · exact rotationDot_18_11_checked
  · exact rotationDot_18_12_checked
  · exact rotationDot_18_13_checked
  · exact rotationDot_18_14_checked
  · exact rotationDot_18_15_checked
  · exact rotationDot_18_16_checked
  · exact rotationDot_18_17_checked
  · exact rotationDot_18_18_checked
  · exact rotationDot_18_19_checked
  · exact rotationDot_18_20_checked
  · exact rotationDot_18_21_checked
  · exact rotationDot_18_22_checked
  · exact rotationDot_18_23_checked
  · exact rotationDot_18_24_checked
  · exact rotationDot_18_25_checked
  · exact rotationDot_18_26_checked
def rotationDot_19_0 : DotRecipe where
  left := fun i => #[11,11,18][i]?.getD 0
  right := fun i => #[11,5,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_19_0_checked : rotationDot_19_0.ExtendedCheck nodes 3 := by decide
def rotationDot_19_1 : DotRecipe where
  left := fun i => #[11,11,18][i]?.getD 0
  right := fun i => #[14,11,0][i]?.getD 0
  product := fun i => #[11,11,2392][i]?.getD 0
  accumulator := fun i => #[11,11,11,2392][i]?.getD 0
theorem rotationDot_19_1_checked : rotationDot_19_1.ExtendedCheck nodes 3 := by decide
def rotationDot_19_2 : DotRecipe where
  left := fun i => #[11,11,18][i]?.getD 0
  right := fun i => #[11,20,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_19_2_checked : rotationDot_19_2.ExtendedCheck nodes 3 := by decide
def rotationDot_19_3 : DotRecipe where
  left := fun i => #[11,11,18][i]?.getD 0
  right := fun i => #[11,5,113][i]?.getD 0
  product := fun i => #[11,11,2394][i]?.getD 0
  accumulator := fun i => #[11,11,11,2394][i]?.getD 0
theorem rotationDot_19_3_checked : rotationDot_19_3.ExtendedCheck nodes 3 := by decide
def rotationDot_19_4 : DotRecipe where
  left := fun i => #[11,11,18][i]?.getD 0
  right := fun i => #[14,11,15][i]?.getD 0
  product := fun i => #[11,11,2396][i]?.getD 0
  accumulator := fun i => #[11,11,11,2396][i]?.getD 0
theorem rotationDot_19_4_checked : rotationDot_19_4.ExtendedCheck nodes 3 := by decide
def rotationDot_19_5 : DotRecipe where
  left := fun i => #[11,11,18][i]?.getD 0
  right := fun i => #[16,111,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_19_5_checked : rotationDot_19_5.ExtendedCheck nodes 3 := by decide
def rotationDot_19_6 : DotRecipe where
  left := fun i => #[11,11,18][i]?.getD 0
  right := fun i => #[11,5,265][i]?.getD 0
  product := fun i => #[11,11,2398][i]?.getD 0
  accumulator := fun i => #[11,11,11,2398][i]?.getD 0
theorem rotationDot_19_6_checked : rotationDot_19_6.ExtendedCheck nodes 3 := by decide
def rotationDot_19_7 : DotRecipe where
  left := fun i => #[11,11,18][i]?.getD 0
  right := fun i => #[14,11,15][i]?.getD 0
  product := fun i => #[11,11,2396][i]?.getD 0
  accumulator := fun i => #[11,11,11,2396][i]?.getD 0
theorem rotationDot_19_7_checked : rotationDot_19_7.ExtendedCheck nodes 3 := by decide
def rotationDot_19_8 : DotRecipe where
  left := fun i => #[11,11,18][i]?.getD 0
  right := fun i => #[17,111,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_19_8_checked : rotationDot_19_8.ExtendedCheck nodes 3 := by decide
def rotationDot_19_9 : DotRecipe where
  left := fun i => #[11,11,18][i]?.getD 0
  right := fun i => #[11,14,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_19_9_checked : rotationDot_19_9.ExtendedCheck nodes 3 := by decide
def rotationDot_19_10 : DotRecipe where
  left := fun i => #[11,11,18][i]?.getD 0
  right := fun i => #[488,11,0][i]?.getD 0
  product := fun i => #[11,11,2392][i]?.getD 0
  accumulator := fun i => #[11,11,11,2392][i]?.getD 0
theorem rotationDot_19_10_checked : rotationDot_19_10.ExtendedCheck nodes 3 := by decide
def rotationDot_19_11 : DotRecipe where
  left := fun i => #[11,11,18][i]?.getD 0
  right := fun i => #[11,20,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_19_11_checked : rotationDot_19_11.ExtendedCheck nodes 3 := by decide
def rotationDot_19_12 : DotRecipe where
  left := fun i => #[11,11,18][i]?.getD 0
  right := fun i => #[11,14,113][i]?.getD 0
  product := fun i => #[11,11,2394][i]?.getD 0
  accumulator := fun i => #[11,11,11,2394][i]?.getD 0
theorem rotationDot_19_12_checked : rotationDot_19_12.ExtendedCheck nodes 3 := by decide
def rotationDot_19_13 : DotRecipe where
  left := fun i => #[11,11,18][i]?.getD 0
  right := fun i => #[488,11,15][i]?.getD 0
  product := fun i => #[11,11,2396][i]?.getD 0
  accumulator := fun i => #[11,11,11,2396][i]?.getD 0
theorem rotationDot_19_13_checked : rotationDot_19_13.ExtendedCheck nodes 3 := by decide
def rotationDot_19_14 : DotRecipe where
  left := fun i => #[11,11,18][i]?.getD 0
  right := fun i => #[16,111,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_19_14_checked : rotationDot_19_14.ExtendedCheck nodes 3 := by decide
def rotationDot_19_15 : DotRecipe where
  left := fun i => #[11,11,18][i]?.getD 0
  right := fun i => #[11,14,265][i]?.getD 0
  product := fun i => #[11,11,2398][i]?.getD 0
  accumulator := fun i => #[11,11,11,2398][i]?.getD 0
theorem rotationDot_19_15_checked : rotationDot_19_15.ExtendedCheck nodes 3 := by decide
def rotationDot_19_16 : DotRecipe where
  left := fun i => #[11,11,18][i]?.getD 0
  right := fun i => #[488,11,15][i]?.getD 0
  product := fun i => #[11,11,2396][i]?.getD 0
  accumulator := fun i => #[11,11,11,2396][i]?.getD 0
theorem rotationDot_19_16_checked : rotationDot_19_16.ExtendedCheck nodes 3 := by decide
def rotationDot_19_17 : DotRecipe where
  left := fun i => #[11,11,18][i]?.getD 0
  right := fun i => #[17,111,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_19_17_checked : rotationDot_19_17.ExtendedCheck nodes 3 := by decide
def rotationDot_19_18 : DotRecipe where
  left := fun i => #[11,11,18][i]?.getD 0
  right := fun i => #[11,11,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_19_18_checked : rotationDot_19_18.ExtendedCheck nodes 3 := by decide
def rotationDot_19_19 : DotRecipe where
  left := fun i => #[11,11,18][i]?.getD 0
  right := fun i => #[11,11,18][i]?.getD 0
  product := fun i => #[11,11,2][i]?.getD 0
  accumulator := fun i => #[11,11,11,2][i]?.getD 0
theorem rotationDot_19_19_checked : rotationDot_19_19.ExtendedCheck nodes 3 := by decide
def rotationDot_19_20 : DotRecipe where
  left := fun i => #[11,11,18][i]?.getD 0
  right := fun i => #[11,2,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_19_20_checked : rotationDot_19_20.ExtendedCheck nodes 3 := by decide
def rotationDot_19_21 : DotRecipe where
  left := fun i => #[11,11,18][i]?.getD 0
  right := fun i => #[11,11,19][i]?.getD 0
  product := fun i => #[11,11,2407][i]?.getD 0
  accumulator := fun i => #[11,11,11,2407][i]?.getD 0
theorem rotationDot_19_21_checked : rotationDot_19_21.ExtendedCheck nodes 3 := by decide
def rotationDot_19_22 : DotRecipe where
  left := fun i => #[11,11,18][i]?.getD 0
  right := fun i => #[11,11,9][i]?.getD 0
  product := fun i => #[11,11,12][i]?.getD 0
  accumulator := fun i => #[11,11,11,12][i]?.getD 0
theorem rotationDot_19_22_checked : rotationDot_19_22.ExtendedCheck nodes 3 := by decide
def rotationDot_19_23 : DotRecipe where
  left := fun i => #[11,11,18][i]?.getD 0
  right := fun i => #[13,12,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_19_23_checked : rotationDot_19_23.ExtendedCheck nodes 3 := by decide
def rotationDot_19_24 : DotRecipe where
  left := fun i => #[11,11,18][i]?.getD 0
  right := fun i => #[11,11,1926][i]?.getD 0
  product := fun i => #[11,11,2410][i]?.getD 0
  accumulator := fun i => #[11,11,11,2410][i]?.getD 0
theorem rotationDot_19_24_checked : rotationDot_19_24.ExtendedCheck nodes 3 := by decide
def rotationDot_19_25 : DotRecipe where
  left := fun i => #[11,11,18][i]?.getD 0
  right := fun i => #[11,11,9][i]?.getD 0
  product := fun i => #[11,11,12][i]?.getD 0
  accumulator := fun i => #[11,11,11,12][i]?.getD 0
theorem rotationDot_19_25_checked : rotationDot_19_25.ExtendedCheck nodes 3 := by decide
def rotationDot_19_26 : DotRecipe where
  left := fun i => #[11,11,18][i]?.getD 0
  right := fun i => #[19,12,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_19_26_checked : rotationDot_19_26.ExtendedCheck nodes 3 := by decide
def rotationDotsRow19 : Array DotRecipe := #[rotationDot_19_0,rotationDot_19_1,rotationDot_19_2,rotationDot_19_3,rotationDot_19_4,rotationDot_19_5,rotationDot_19_6,rotationDot_19_7,rotationDot_19_8,rotationDot_19_9,rotationDot_19_10,rotationDot_19_11,rotationDot_19_12,rotationDot_19_13,rotationDot_19_14,rotationDot_19_15,rotationDot_19_16,rotationDot_19_17,rotationDot_19_18,rotationDot_19_19,rotationDot_19_20,rotationDot_19_21,rotationDot_19_22,rotationDot_19_23,rotationDot_19_24,rotationDot_19_25,rotationDot_19_26]
theorem rotationDotsRow19_checked (j : Fin 27) :
    (rotationDotsRow19[j.val]?.getD rotationDot_0_0).ExtendedCheck nodes 3 := by
  fin_cases j
  · exact rotationDot_19_0_checked
  · exact rotationDot_19_1_checked
  · exact rotationDot_19_2_checked
  · exact rotationDot_19_3_checked
  · exact rotationDot_19_4_checked
  · exact rotationDot_19_5_checked
  · exact rotationDot_19_6_checked
  · exact rotationDot_19_7_checked
  · exact rotationDot_19_8_checked
  · exact rotationDot_19_9_checked
  · exact rotationDot_19_10_checked
  · exact rotationDot_19_11_checked
  · exact rotationDot_19_12_checked
  · exact rotationDot_19_13_checked
  · exact rotationDot_19_14_checked
  · exact rotationDot_19_15_checked
  · exact rotationDot_19_16_checked
  · exact rotationDot_19_17_checked
  · exact rotationDot_19_18_checked
  · exact rotationDot_19_19_checked
  · exact rotationDot_19_20_checked
  · exact rotationDot_19_21_checked
  · exact rotationDot_19_22_checked
  · exact rotationDot_19_23_checked
  · exact rotationDot_19_24_checked
  · exact rotationDot_19_25_checked
  · exact rotationDot_19_26_checked
def rotationDot_20_0 : DotRecipe where
  left := fun i => #[11,2,11][i]?.getD 0
  right := fun i => #[11,5,11][i]?.getD 0
  product := fun i => #[11,5,11][i]?.getD 0
  accumulator := fun i => #[11,11,5,5][i]?.getD 0
theorem rotationDot_20_0_checked : rotationDot_20_0.ExtendedCheck nodes 3 := by decide
def rotationDot_20_1 : DotRecipe where
  left := fun i => #[11,2,11][i]?.getD 0
  right := fun i => #[14,11,0][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_20_1_checked : rotationDot_20_1.ExtendedCheck nodes 3 := by decide
def rotationDot_20_2 : DotRecipe where
  left := fun i => #[11,2,11][i]?.getD 0
  right := fun i => #[11,20,11][i]?.getD 0
  product := fun i => #[11,20,11][i]?.getD 0
  accumulator := fun i => #[11,11,20,20][i]?.getD 0
theorem rotationDot_20_2_checked : rotationDot_20_2.ExtendedCheck nodes 3 := by decide
def rotationDot_20_3 : DotRecipe where
  left := fun i => #[11,2,11][i]?.getD 0
  right := fun i => #[11,5,113][i]?.getD 0
  product := fun i => #[11,5,11][i]?.getD 0
  accumulator := fun i => #[11,11,5,5][i]?.getD 0
theorem rotationDot_20_3_checked : rotationDot_20_3.ExtendedCheck nodes 3 := by decide
def rotationDot_20_4 : DotRecipe where
  left := fun i => #[11,2,11][i]?.getD 0
  right := fun i => #[14,11,15][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_20_4_checked : rotationDot_20_4.ExtendedCheck nodes 3 := by decide
def rotationDot_20_5 : DotRecipe where
  left := fun i => #[11,2,11][i]?.getD 0
  right := fun i => #[16,111,11][i]?.getD 0
  product := fun i => #[11,111,11][i]?.getD 0
  accumulator := fun i => #[11,11,111,111][i]?.getD 0
theorem rotationDot_20_5_checked : rotationDot_20_5.ExtendedCheck nodes 3 := by decide
def rotationDot_20_6 : DotRecipe where
  left := fun i => #[11,2,11][i]?.getD 0
  right := fun i => #[11,5,265][i]?.getD 0
  product := fun i => #[11,5,11][i]?.getD 0
  accumulator := fun i => #[11,11,5,5][i]?.getD 0
theorem rotationDot_20_6_checked : rotationDot_20_6.ExtendedCheck nodes 3 := by decide
def rotationDot_20_7 : DotRecipe where
  left := fun i => #[11,2,11][i]?.getD 0
  right := fun i => #[14,11,15][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_20_7_checked : rotationDot_20_7.ExtendedCheck nodes 3 := by decide
def rotationDot_20_8 : DotRecipe where
  left := fun i => #[11,2,11][i]?.getD 0
  right := fun i => #[17,111,11][i]?.getD 0
  product := fun i => #[11,111,11][i]?.getD 0
  accumulator := fun i => #[11,11,111,111][i]?.getD 0
theorem rotationDot_20_8_checked : rotationDot_20_8.ExtendedCheck nodes 3 := by decide
def rotationDot_20_9 : DotRecipe where
  left := fun i => #[11,2,11][i]?.getD 0
  right := fun i => #[11,14,11][i]?.getD 0
  product := fun i => #[11,14,11][i]?.getD 0
  accumulator := fun i => #[11,11,14,14][i]?.getD 0
theorem rotationDot_20_9_checked : rotationDot_20_9.ExtendedCheck nodes 3 := by decide
def rotationDot_20_10 : DotRecipe where
  left := fun i => #[11,2,11][i]?.getD 0
  right := fun i => #[488,11,0][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_20_10_checked : rotationDot_20_10.ExtendedCheck nodes 3 := by decide
def rotationDot_20_11 : DotRecipe where
  left := fun i => #[11,2,11][i]?.getD 0
  right := fun i => #[11,20,11][i]?.getD 0
  product := fun i => #[11,20,11][i]?.getD 0
  accumulator := fun i => #[11,11,20,20][i]?.getD 0
theorem rotationDot_20_11_checked : rotationDot_20_11.ExtendedCheck nodes 3 := by decide
def rotationDot_20_12 : DotRecipe where
  left := fun i => #[11,2,11][i]?.getD 0
  right := fun i => #[11,14,113][i]?.getD 0
  product := fun i => #[11,14,11][i]?.getD 0
  accumulator := fun i => #[11,11,14,14][i]?.getD 0
theorem rotationDot_20_12_checked : rotationDot_20_12.ExtendedCheck nodes 3 := by decide
def rotationDot_20_13 : DotRecipe where
  left := fun i => #[11,2,11][i]?.getD 0
  right := fun i => #[488,11,15][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_20_13_checked : rotationDot_20_13.ExtendedCheck nodes 3 := by decide
def rotationDot_20_14 : DotRecipe where
  left := fun i => #[11,2,11][i]?.getD 0
  right := fun i => #[16,111,11][i]?.getD 0
  product := fun i => #[11,111,11][i]?.getD 0
  accumulator := fun i => #[11,11,111,111][i]?.getD 0
theorem rotationDot_20_14_checked : rotationDot_20_14.ExtendedCheck nodes 3 := by decide
def rotationDot_20_15 : DotRecipe where
  left := fun i => #[11,2,11][i]?.getD 0
  right := fun i => #[11,14,265][i]?.getD 0
  product := fun i => #[11,14,11][i]?.getD 0
  accumulator := fun i => #[11,11,14,14][i]?.getD 0
theorem rotationDot_20_15_checked : rotationDot_20_15.ExtendedCheck nodes 3 := by decide
def rotationDot_20_16 : DotRecipe where
  left := fun i => #[11,2,11][i]?.getD 0
  right := fun i => #[488,11,15][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_20_16_checked : rotationDot_20_16.ExtendedCheck nodes 3 := by decide
def rotationDot_20_17 : DotRecipe where
  left := fun i => #[11,2,11][i]?.getD 0
  right := fun i => #[17,111,11][i]?.getD 0
  product := fun i => #[11,111,11][i]?.getD 0
  accumulator := fun i => #[11,11,111,111][i]?.getD 0
theorem rotationDot_20_17_checked : rotationDot_20_17.ExtendedCheck nodes 3 := by decide
def rotationDot_20_18 : DotRecipe where
  left := fun i => #[11,2,11][i]?.getD 0
  right := fun i => #[11,11,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_20_18_checked : rotationDot_20_18.ExtendedCheck nodes 3 := by decide
def rotationDot_20_19 : DotRecipe where
  left := fun i => #[11,2,11][i]?.getD 0
  right := fun i => #[11,11,18][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_20_19_checked : rotationDot_20_19.ExtendedCheck nodes 3 := by decide
def rotationDot_20_20 : DotRecipe where
  left := fun i => #[11,2,11][i]?.getD 0
  right := fun i => #[11,2,11][i]?.getD 0
  product := fun i => #[11,2,11][i]?.getD 0
  accumulator := fun i => #[11,11,2,2][i]?.getD 0
theorem rotationDot_20_20_checked : rotationDot_20_20.ExtendedCheck nodes 3 := by decide
def rotationDot_20_21 : DotRecipe where
  left := fun i => #[11,2,11][i]?.getD 0
  right := fun i => #[11,11,19][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_20_21_checked : rotationDot_20_21.ExtendedCheck nodes 3 := by decide
def rotationDot_20_22 : DotRecipe where
  left := fun i => #[11,2,11][i]?.getD 0
  right := fun i => #[11,11,9][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_20_22_checked : rotationDot_20_22.ExtendedCheck nodes 3 := by decide
def rotationDot_20_23 : DotRecipe where
  left := fun i => #[11,2,11][i]?.getD 0
  right := fun i => #[13,12,11][i]?.getD 0
  product := fun i => #[11,12,11][i]?.getD 0
  accumulator := fun i => #[11,11,12,12][i]?.getD 0
theorem rotationDot_20_23_checked : rotationDot_20_23.ExtendedCheck nodes 3 := by decide
def rotationDot_20_24 : DotRecipe where
  left := fun i => #[11,2,11][i]?.getD 0
  right := fun i => #[11,11,1926][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_20_24_checked : rotationDot_20_24.ExtendedCheck nodes 3 := by decide
def rotationDot_20_25 : DotRecipe where
  left := fun i => #[11,2,11][i]?.getD 0
  right := fun i => #[11,11,9][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_20_25_checked : rotationDot_20_25.ExtendedCheck nodes 3 := by decide
def rotationDot_20_26 : DotRecipe where
  left := fun i => #[11,2,11][i]?.getD 0
  right := fun i => #[19,12,11][i]?.getD 0
  product := fun i => #[11,12,11][i]?.getD 0
  accumulator := fun i => #[11,11,12,12][i]?.getD 0
theorem rotationDot_20_26_checked : rotationDot_20_26.ExtendedCheck nodes 3 := by decide
def rotationDotsRow20 : Array DotRecipe := #[rotationDot_20_0,rotationDot_20_1,rotationDot_20_2,rotationDot_20_3,rotationDot_20_4,rotationDot_20_5,rotationDot_20_6,rotationDot_20_7,rotationDot_20_8,rotationDot_20_9,rotationDot_20_10,rotationDot_20_11,rotationDot_20_12,rotationDot_20_13,rotationDot_20_14,rotationDot_20_15,rotationDot_20_16,rotationDot_20_17,rotationDot_20_18,rotationDot_20_19,rotationDot_20_20,rotationDot_20_21,rotationDot_20_22,rotationDot_20_23,rotationDot_20_24,rotationDot_20_25,rotationDot_20_26]
theorem rotationDotsRow20_checked (j : Fin 27) :
    (rotationDotsRow20[j.val]?.getD rotationDot_0_0).ExtendedCheck nodes 3 := by
  fin_cases j
  · exact rotationDot_20_0_checked
  · exact rotationDot_20_1_checked
  · exact rotationDot_20_2_checked
  · exact rotationDot_20_3_checked
  · exact rotationDot_20_4_checked
  · exact rotationDot_20_5_checked
  · exact rotationDot_20_6_checked
  · exact rotationDot_20_7_checked
  · exact rotationDot_20_8_checked
  · exact rotationDot_20_9_checked
  · exact rotationDot_20_10_checked
  · exact rotationDot_20_11_checked
  · exact rotationDot_20_12_checked
  · exact rotationDot_20_13_checked
  · exact rotationDot_20_14_checked
  · exact rotationDot_20_15_checked
  · exact rotationDot_20_16_checked
  · exact rotationDot_20_17_checked
  · exact rotationDot_20_18_checked
  · exact rotationDot_20_19_checked
  · exact rotationDot_20_20_checked
  · exact rotationDot_20_21_checked
  · exact rotationDot_20_22_checked
  · exact rotationDot_20_23_checked
  · exact rotationDot_20_24_checked
  · exact rotationDot_20_25_checked
  · exact rotationDot_20_26_checked
def rotationDot_21_0 : DotRecipe where
  left := fun i => #[11,11,19][i]?.getD 0
  right := fun i => #[11,5,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_21_0_checked : rotationDot_21_0.ExtendedCheck nodes 3 := by decide
def rotationDot_21_1 : DotRecipe where
  left := fun i => #[11,11,19][i]?.getD 0
  right := fun i => #[14,11,0][i]?.getD 0
  product := fun i => #[11,11,2422][i]?.getD 0
  accumulator := fun i => #[11,11,11,2422][i]?.getD 0
theorem rotationDot_21_1_checked : rotationDot_21_1.ExtendedCheck nodes 3 := by decide
def rotationDot_21_2 : DotRecipe where
  left := fun i => #[11,11,19][i]?.getD 0
  right := fun i => #[11,20,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_21_2_checked : rotationDot_21_2.ExtendedCheck nodes 3 := by decide
def rotationDot_21_3 : DotRecipe where
  left := fun i => #[11,11,19][i]?.getD 0
  right := fun i => #[11,5,113][i]?.getD 0
  product := fun i => #[11,11,2424][i]?.getD 0
  accumulator := fun i => #[11,11,11,2424][i]?.getD 0
theorem rotationDot_21_3_checked : rotationDot_21_3.ExtendedCheck nodes 3 := by decide
def rotationDot_21_4 : DotRecipe where
  left := fun i => #[11,11,19][i]?.getD 0
  right := fun i => #[14,11,15][i]?.getD 0
  product := fun i => #[11,11,2426][i]?.getD 0
  accumulator := fun i => #[11,11,11,2426][i]?.getD 0
theorem rotationDot_21_4_checked : rotationDot_21_4.ExtendedCheck nodes 3 := by decide
def rotationDot_21_5 : DotRecipe where
  left := fun i => #[11,11,19][i]?.getD 0
  right := fun i => #[16,111,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_21_5_checked : rotationDot_21_5.ExtendedCheck nodes 3 := by decide
def rotationDot_21_6 : DotRecipe where
  left := fun i => #[11,11,19][i]?.getD 0
  right := fun i => #[11,5,265][i]?.getD 0
  product := fun i => #[11,11,2428][i]?.getD 0
  accumulator := fun i => #[11,11,11,2428][i]?.getD 0
theorem rotationDot_21_6_checked : rotationDot_21_6.ExtendedCheck nodes 3 := by decide
def rotationDot_21_7 : DotRecipe where
  left := fun i => #[11,11,19][i]?.getD 0
  right := fun i => #[14,11,15][i]?.getD 0
  product := fun i => #[11,11,2426][i]?.getD 0
  accumulator := fun i => #[11,11,11,2426][i]?.getD 0
theorem rotationDot_21_7_checked : rotationDot_21_7.ExtendedCheck nodes 3 := by decide
def rotationDot_21_8 : DotRecipe where
  left := fun i => #[11,11,19][i]?.getD 0
  right := fun i => #[17,111,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_21_8_checked : rotationDot_21_8.ExtendedCheck nodes 3 := by decide
def rotationDot_21_9 : DotRecipe where
  left := fun i => #[11,11,19][i]?.getD 0
  right := fun i => #[11,14,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_21_9_checked : rotationDot_21_9.ExtendedCheck nodes 3 := by decide
def rotationDot_21_10 : DotRecipe where
  left := fun i => #[11,11,19][i]?.getD 0
  right := fun i => #[488,11,0][i]?.getD 0
  product := fun i => #[11,11,2422][i]?.getD 0
  accumulator := fun i => #[11,11,11,2422][i]?.getD 0
theorem rotationDot_21_10_checked : rotationDot_21_10.ExtendedCheck nodes 3 := by decide
def rotationDot_21_11 : DotRecipe where
  left := fun i => #[11,11,19][i]?.getD 0
  right := fun i => #[11,20,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_21_11_checked : rotationDot_21_11.ExtendedCheck nodes 3 := by decide
def rotationDot_21_12 : DotRecipe where
  left := fun i => #[11,11,19][i]?.getD 0
  right := fun i => #[11,14,113][i]?.getD 0
  product := fun i => #[11,11,2424][i]?.getD 0
  accumulator := fun i => #[11,11,11,2424][i]?.getD 0
theorem rotationDot_21_12_checked : rotationDot_21_12.ExtendedCheck nodes 3 := by decide
def rotationDot_21_13 : DotRecipe where
  left := fun i => #[11,11,19][i]?.getD 0
  right := fun i => #[488,11,15][i]?.getD 0
  product := fun i => #[11,11,2426][i]?.getD 0
  accumulator := fun i => #[11,11,11,2426][i]?.getD 0
theorem rotationDot_21_13_checked : rotationDot_21_13.ExtendedCheck nodes 3 := by decide
def rotationDot_21_14 : DotRecipe where
  left := fun i => #[11,11,19][i]?.getD 0
  right := fun i => #[16,111,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_21_14_checked : rotationDot_21_14.ExtendedCheck nodes 3 := by decide
def rotationDot_21_15 : DotRecipe where
  left := fun i => #[11,11,19][i]?.getD 0
  right := fun i => #[11,14,265][i]?.getD 0
  product := fun i => #[11,11,2428][i]?.getD 0
  accumulator := fun i => #[11,11,11,2428][i]?.getD 0
theorem rotationDot_21_15_checked : rotationDot_21_15.ExtendedCheck nodes 3 := by decide
def rotationDot_21_16 : DotRecipe where
  left := fun i => #[11,11,19][i]?.getD 0
  right := fun i => #[488,11,15][i]?.getD 0
  product := fun i => #[11,11,2426][i]?.getD 0
  accumulator := fun i => #[11,11,11,2426][i]?.getD 0
theorem rotationDot_21_16_checked : rotationDot_21_16.ExtendedCheck nodes 3 := by decide
def rotationDot_21_17 : DotRecipe where
  left := fun i => #[11,11,19][i]?.getD 0
  right := fun i => #[17,111,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_21_17_checked : rotationDot_21_17.ExtendedCheck nodes 3 := by decide
def rotationDot_21_18 : DotRecipe where
  left := fun i => #[11,11,19][i]?.getD 0
  right := fun i => #[11,11,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_21_18_checked : rotationDot_21_18.ExtendedCheck nodes 3 := by decide
def rotationDot_21_19 : DotRecipe where
  left := fun i => #[11,11,19][i]?.getD 0
  right := fun i => #[11,11,18][i]?.getD 0
  product := fun i => #[11,11,2436][i]?.getD 0
  accumulator := fun i => #[11,11,11,2436][i]?.getD 0
theorem rotationDot_21_19_checked : rotationDot_21_19.ExtendedCheck nodes 3 := by decide
def rotationDot_21_20 : DotRecipe where
  left := fun i => #[11,11,19][i]?.getD 0
  right := fun i => #[11,2,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_21_20_checked : rotationDot_21_20.ExtendedCheck nodes 3 := by decide
def rotationDot_21_21 : DotRecipe where
  left := fun i => #[11,11,19][i]?.getD 0
  right := fun i => #[11,11,19][i]?.getD 0
  product := fun i => #[11,11,1493][i]?.getD 0
  accumulator := fun i => #[11,11,11,1493][i]?.getD 0
theorem rotationDot_21_21_checked : rotationDot_21_21.ExtendedCheck nodes 3 := by decide
def rotationDot_21_22 : DotRecipe where
  left := fun i => #[11,11,19][i]?.getD 0
  right := fun i => #[11,11,9][i]?.getD 0
  product := fun i => #[11,11,2439][i]?.getD 0
  accumulator := fun i => #[11,11,11,2439][i]?.getD 0
theorem rotationDot_21_22_checked : rotationDot_21_22.ExtendedCheck nodes 3 := by decide
def rotationDot_21_23 : DotRecipe where
  left := fun i => #[11,11,19][i]?.getD 0
  right := fun i => #[13,12,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_21_23_checked : rotationDot_21_23.ExtendedCheck nodes 3 := by decide
def rotationDot_21_24 : DotRecipe where
  left := fun i => #[11,11,19][i]?.getD 0
  right := fun i => #[11,11,1926][i]?.getD 0
  product := fun i => #[11,11,2441][i]?.getD 0
  accumulator := fun i => #[11,11,11,2441][i]?.getD 0
theorem rotationDot_21_24_checked : rotationDot_21_24.ExtendedCheck nodes 3 := by decide
def rotationDot_21_25 : DotRecipe where
  left := fun i => #[11,11,19][i]?.getD 0
  right := fun i => #[11,11,9][i]?.getD 0
  product := fun i => #[11,11,2439][i]?.getD 0
  accumulator := fun i => #[11,11,11,2439][i]?.getD 0
theorem rotationDot_21_25_checked : rotationDot_21_25.ExtendedCheck nodes 3 := by decide
def rotationDot_21_26 : DotRecipe where
  left := fun i => #[11,11,19][i]?.getD 0
  right := fun i => #[19,12,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_21_26_checked : rotationDot_21_26.ExtendedCheck nodes 3 := by decide
def rotationDotsRow21 : Array DotRecipe := #[rotationDot_21_0,rotationDot_21_1,rotationDot_21_2,rotationDot_21_3,rotationDot_21_4,rotationDot_21_5,rotationDot_21_6,rotationDot_21_7,rotationDot_21_8,rotationDot_21_9,rotationDot_21_10,rotationDot_21_11,rotationDot_21_12,rotationDot_21_13,rotationDot_21_14,rotationDot_21_15,rotationDot_21_16,rotationDot_21_17,rotationDot_21_18,rotationDot_21_19,rotationDot_21_20,rotationDot_21_21,rotationDot_21_22,rotationDot_21_23,rotationDot_21_24,rotationDot_21_25,rotationDot_21_26]
theorem rotationDotsRow21_checked (j : Fin 27) :
    (rotationDotsRow21[j.val]?.getD rotationDot_0_0).ExtendedCheck nodes 3 := by
  fin_cases j
  · exact rotationDot_21_0_checked
  · exact rotationDot_21_1_checked
  · exact rotationDot_21_2_checked
  · exact rotationDot_21_3_checked
  · exact rotationDot_21_4_checked
  · exact rotationDot_21_5_checked
  · exact rotationDot_21_6_checked
  · exact rotationDot_21_7_checked
  · exact rotationDot_21_8_checked
  · exact rotationDot_21_9_checked
  · exact rotationDot_21_10_checked
  · exact rotationDot_21_11_checked
  · exact rotationDot_21_12_checked
  · exact rotationDot_21_13_checked
  · exact rotationDot_21_14_checked
  · exact rotationDot_21_15_checked
  · exact rotationDot_21_16_checked
  · exact rotationDot_21_17_checked
  · exact rotationDot_21_18_checked
  · exact rotationDot_21_19_checked
  · exact rotationDot_21_20_checked
  · exact rotationDot_21_21_checked
  · exact rotationDot_21_22_checked
  · exact rotationDot_21_23_checked
  · exact rotationDot_21_24_checked
  · exact rotationDot_21_25_checked
  · exact rotationDot_21_26_checked
def rotationDot_22_0 : DotRecipe where
  left := fun i => #[11,11,9][i]?.getD 0
  right := fun i => #[11,5,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_22_0_checked : rotationDot_22_0.ExtendedCheck nodes 3 := by decide
def rotationDot_22_1 : DotRecipe where
  left := fun i => #[11,11,9][i]?.getD 0
  right := fun i => #[14,11,0][i]?.getD 0
  product := fun i => #[11,11,2443][i]?.getD 0
  accumulator := fun i => #[11,11,11,2443][i]?.getD 0
theorem rotationDot_22_1_checked : rotationDot_22_1.ExtendedCheck nodes 3 := by decide
def rotationDot_22_2 : DotRecipe where
  left := fun i => #[11,11,9][i]?.getD 0
  right := fun i => #[11,20,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_22_2_checked : rotationDot_22_2.ExtendedCheck nodes 3 := by decide
def rotationDot_22_3 : DotRecipe where
  left := fun i => #[11,11,9][i]?.getD 0
  right := fun i => #[11,5,113][i]?.getD 0
  product := fun i => #[11,11,2445][i]?.getD 0
  accumulator := fun i => #[11,11,11,2445][i]?.getD 0
theorem rotationDot_22_3_checked : rotationDot_22_3.ExtendedCheck nodes 3 := by decide
def rotationDot_22_4 : DotRecipe where
  left := fun i => #[11,11,9][i]?.getD 0
  right := fun i => #[14,11,15][i]?.getD 0
  product := fun i => #[11,11,2447][i]?.getD 0
  accumulator := fun i => #[11,11,11,2447][i]?.getD 0
theorem rotationDot_22_4_checked : rotationDot_22_4.ExtendedCheck nodes 3 := by decide
def rotationDot_22_5 : DotRecipe where
  left := fun i => #[11,11,9][i]?.getD 0
  right := fun i => #[16,111,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_22_5_checked : rotationDot_22_5.ExtendedCheck nodes 3 := by decide
def rotationDot_22_6 : DotRecipe where
  left := fun i => #[11,11,9][i]?.getD 0
  right := fun i => #[11,5,265][i]?.getD 0
  product := fun i => #[11,11,2449][i]?.getD 0
  accumulator := fun i => #[11,11,11,2449][i]?.getD 0
theorem rotationDot_22_6_checked : rotationDot_22_6.ExtendedCheck nodes 3 := by decide
def rotationDot_22_7 : DotRecipe where
  left := fun i => #[11,11,9][i]?.getD 0
  right := fun i => #[14,11,15][i]?.getD 0
  product := fun i => #[11,11,2447][i]?.getD 0
  accumulator := fun i => #[11,11,11,2447][i]?.getD 0
theorem rotationDot_22_7_checked : rotationDot_22_7.ExtendedCheck nodes 3 := by decide
def rotationDot_22_8 : DotRecipe where
  left := fun i => #[11,11,9][i]?.getD 0
  right := fun i => #[17,111,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_22_8_checked : rotationDot_22_8.ExtendedCheck nodes 3 := by decide
def rotationDot_22_9 : DotRecipe where
  left := fun i => #[11,11,9][i]?.getD 0
  right := fun i => #[11,14,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_22_9_checked : rotationDot_22_9.ExtendedCheck nodes 3 := by decide
def rotationDot_22_10 : DotRecipe where
  left := fun i => #[11,11,9][i]?.getD 0
  right := fun i => #[488,11,0][i]?.getD 0
  product := fun i => #[11,11,2443][i]?.getD 0
  accumulator := fun i => #[11,11,11,2443][i]?.getD 0
theorem rotationDot_22_10_checked : rotationDot_22_10.ExtendedCheck nodes 3 := by decide
def rotationDot_22_11 : DotRecipe where
  left := fun i => #[11,11,9][i]?.getD 0
  right := fun i => #[11,20,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_22_11_checked : rotationDot_22_11.ExtendedCheck nodes 3 := by decide
def rotationDot_22_12 : DotRecipe where
  left := fun i => #[11,11,9][i]?.getD 0
  right := fun i => #[11,14,113][i]?.getD 0
  product := fun i => #[11,11,2445][i]?.getD 0
  accumulator := fun i => #[11,11,11,2445][i]?.getD 0
theorem rotationDot_22_12_checked : rotationDot_22_12.ExtendedCheck nodes 3 := by decide
def rotationDot_22_13 : DotRecipe where
  left := fun i => #[11,11,9][i]?.getD 0
  right := fun i => #[488,11,15][i]?.getD 0
  product := fun i => #[11,11,2447][i]?.getD 0
  accumulator := fun i => #[11,11,11,2447][i]?.getD 0
theorem rotationDot_22_13_checked : rotationDot_22_13.ExtendedCheck nodes 3 := by decide
def rotationDot_22_14 : DotRecipe where
  left := fun i => #[11,11,9][i]?.getD 0
  right := fun i => #[16,111,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_22_14_checked : rotationDot_22_14.ExtendedCheck nodes 3 := by decide
def rotationDot_22_15 : DotRecipe where
  left := fun i => #[11,11,9][i]?.getD 0
  right := fun i => #[11,14,265][i]?.getD 0
  product := fun i => #[11,11,2449][i]?.getD 0
  accumulator := fun i => #[11,11,11,2449][i]?.getD 0
theorem rotationDot_22_15_checked : rotationDot_22_15.ExtendedCheck nodes 3 := by decide
def rotationDot_22_16 : DotRecipe where
  left := fun i => #[11,11,9][i]?.getD 0
  right := fun i => #[488,11,15][i]?.getD 0
  product := fun i => #[11,11,2447][i]?.getD 0
  accumulator := fun i => #[11,11,11,2447][i]?.getD 0
theorem rotationDot_22_16_checked : rotationDot_22_16.ExtendedCheck nodes 3 := by decide
def rotationDot_22_17 : DotRecipe where
  left := fun i => #[11,11,9][i]?.getD 0
  right := fun i => #[17,111,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_22_17_checked : rotationDot_22_17.ExtendedCheck nodes 3 := by decide
def rotationDot_22_18 : DotRecipe where
  left := fun i => #[11,11,9][i]?.getD 0
  right := fun i => #[11,11,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_22_18_checked : rotationDot_22_18.ExtendedCheck nodes 3 := by decide
def rotationDot_22_19 : DotRecipe where
  left := fun i => #[11,11,9][i]?.getD 0
  right := fun i => #[11,11,18][i]?.getD 0
  product := fun i => #[11,11,12][i]?.getD 0
  accumulator := fun i => #[11,11,11,12][i]?.getD 0
theorem rotationDot_22_19_checked : rotationDot_22_19.ExtendedCheck nodes 3 := by decide
def rotationDot_22_20 : DotRecipe where
  left := fun i => #[11,11,9][i]?.getD 0
  right := fun i => #[11,2,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_22_20_checked : rotationDot_22_20.ExtendedCheck nodes 3 := by decide
def rotationDot_22_21 : DotRecipe where
  left := fun i => #[11,11,9][i]?.getD 0
  right := fun i => #[11,11,19][i]?.getD 0
  product := fun i => #[11,11,2457][i]?.getD 0
  accumulator := fun i => #[11,11,11,2457][i]?.getD 0
theorem rotationDot_22_21_checked : rotationDot_22_21.ExtendedCheck nodes 3 := by decide
def rotationDot_22_22 : DotRecipe where
  left := fun i => #[11,11,9][i]?.getD 0
  right := fun i => #[11,11,9][i]?.getD 0
  product := fun i => #[11,11,2459][i]?.getD 0
  accumulator := fun i => #[11,11,11,2459][i]?.getD 0
theorem rotationDot_22_22_checked : rotationDot_22_22.ExtendedCheck nodes 3 := by decide
def rotationDot_22_23 : DotRecipe where
  left := fun i => #[11,11,9][i]?.getD 0
  right := fun i => #[13,12,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_22_23_checked : rotationDot_22_23.ExtendedCheck nodes 3 := by decide
def rotationDot_22_24 : DotRecipe where
  left := fun i => #[11,11,9][i]?.getD 0
  right := fun i => #[11,11,1926][i]?.getD 0
  product := fun i => #[11,11,2461][i]?.getD 0
  accumulator := fun i => #[11,11,11,2461][i]?.getD 0
theorem rotationDot_22_24_checked : rotationDot_22_24.ExtendedCheck nodes 3 := by decide
def rotationDot_22_25 : DotRecipe where
  left := fun i => #[11,11,9][i]?.getD 0
  right := fun i => #[11,11,9][i]?.getD 0
  product := fun i => #[11,11,2459][i]?.getD 0
  accumulator := fun i => #[11,11,11,2459][i]?.getD 0
theorem rotationDot_22_25_checked : rotationDot_22_25.ExtendedCheck nodes 3 := by decide
def rotationDot_22_26 : DotRecipe where
  left := fun i => #[11,11,9][i]?.getD 0
  right := fun i => #[19,12,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_22_26_checked : rotationDot_22_26.ExtendedCheck nodes 3 := by decide
def rotationDotsRow22 : Array DotRecipe := #[rotationDot_22_0,rotationDot_22_1,rotationDot_22_2,rotationDot_22_3,rotationDot_22_4,rotationDot_22_5,rotationDot_22_6,rotationDot_22_7,rotationDot_22_8,rotationDot_22_9,rotationDot_22_10,rotationDot_22_11,rotationDot_22_12,rotationDot_22_13,rotationDot_22_14,rotationDot_22_15,rotationDot_22_16,rotationDot_22_17,rotationDot_22_18,rotationDot_22_19,rotationDot_22_20,rotationDot_22_21,rotationDot_22_22,rotationDot_22_23,rotationDot_22_24,rotationDot_22_25,rotationDot_22_26]
theorem rotationDotsRow22_checked (j : Fin 27) :
    (rotationDotsRow22[j.val]?.getD rotationDot_0_0).ExtendedCheck nodes 3 := by
  fin_cases j
  · exact rotationDot_22_0_checked
  · exact rotationDot_22_1_checked
  · exact rotationDot_22_2_checked
  · exact rotationDot_22_3_checked
  · exact rotationDot_22_4_checked
  · exact rotationDot_22_5_checked
  · exact rotationDot_22_6_checked
  · exact rotationDot_22_7_checked
  · exact rotationDot_22_8_checked
  · exact rotationDot_22_9_checked
  · exact rotationDot_22_10_checked
  · exact rotationDot_22_11_checked
  · exact rotationDot_22_12_checked
  · exact rotationDot_22_13_checked
  · exact rotationDot_22_14_checked
  · exact rotationDot_22_15_checked
  · exact rotationDot_22_16_checked
  · exact rotationDot_22_17_checked
  · exact rotationDot_22_18_checked
  · exact rotationDot_22_19_checked
  · exact rotationDot_22_20_checked
  · exact rotationDot_22_21_checked
  · exact rotationDot_22_22_checked
  · exact rotationDot_22_23_checked
  · exact rotationDot_22_24_checked
  · exact rotationDot_22_25_checked
  · exact rotationDot_22_26_checked
def rotationDot_23_0 : DotRecipe where
  left := fun i => #[13,12,11][i]?.getD 0
  right := fun i => #[11,5,11][i]?.getD 0
  product := fun i => #[11,2463,11][i]?.getD 0
  accumulator := fun i => #[11,11,2463,2463][i]?.getD 0
theorem rotationDot_23_0_checked : rotationDot_23_0.ExtendedCheck nodes 3 := by decide
def rotationDot_23_1 : DotRecipe where
  left := fun i => #[13,12,11][i]?.getD 0
  right := fun i => #[14,11,0][i]?.getD 0
  product := fun i => #[2465,11,11][i]?.getD 0
  accumulator := fun i => #[11,2465,2465,2465][i]?.getD 0
theorem rotationDot_23_1_checked : rotationDot_23_1.ExtendedCheck nodes 3 := by decide
def rotationDot_23_2 : DotRecipe where
  left := fun i => #[13,12,11][i]?.getD 0
  right := fun i => #[11,20,11][i]?.getD 0
  product := fun i => #[11,2467,11][i]?.getD 0
  accumulator := fun i => #[11,11,2467,2467][i]?.getD 0
theorem rotationDot_23_2_checked : rotationDot_23_2.ExtendedCheck nodes 3 := by decide
def rotationDot_23_3 : DotRecipe where
  left := fun i => #[13,12,11][i]?.getD 0
  right := fun i => #[11,5,113][i]?.getD 0
  product := fun i => #[11,2463,11][i]?.getD 0
  accumulator := fun i => #[11,11,2463,2463][i]?.getD 0
theorem rotationDot_23_3_checked : rotationDot_23_3.ExtendedCheck nodes 3 := by decide
def rotationDot_23_4 : DotRecipe where
  left := fun i => #[13,12,11][i]?.getD 0
  right := fun i => #[14,11,15][i]?.getD 0
  product := fun i => #[2465,11,11][i]?.getD 0
  accumulator := fun i => #[11,2465,2465,2465][i]?.getD 0
theorem rotationDot_23_4_checked : rotationDot_23_4.ExtendedCheck nodes 3 := by decide
def rotationDot_23_5 : DotRecipe where
  left := fun i => #[13,12,11][i]?.getD 0
  right := fun i => #[16,111,11][i]?.getD 0
  product := fun i => #[2471,2472,11][i]?.getD 0
  accumulator := fun i => #[11,2471,2473,2473][i]?.getD 0
theorem rotationDot_23_5_checked : rotationDot_23_5.ExtendedCheck nodes 3 := by decide
def rotationDot_23_6 : DotRecipe where
  left := fun i => #[13,12,11][i]?.getD 0
  right := fun i => #[11,5,265][i]?.getD 0
  product := fun i => #[11,2463,11][i]?.getD 0
  accumulator := fun i => #[11,11,2463,2463][i]?.getD 0
theorem rotationDot_23_6_checked : rotationDot_23_6.ExtendedCheck nodes 3 := by decide
def rotationDot_23_7 : DotRecipe where
  left := fun i => #[13,12,11][i]?.getD 0
  right := fun i => #[14,11,15][i]?.getD 0
  product := fun i => #[2465,11,11][i]?.getD 0
  accumulator := fun i => #[11,2465,2465,2465][i]?.getD 0
theorem rotationDot_23_7_checked : rotationDot_23_7.ExtendedCheck nodes 3 := by decide
def rotationDot_23_8 : DotRecipe where
  left := fun i => #[13,12,11][i]?.getD 0
  right := fun i => #[17,111,11][i]?.getD 0
  product := fun i => #[2477,2472,11][i]?.getD 0
  accumulator := fun i => #[11,2477,2478,2478][i]?.getD 0
theorem rotationDot_23_8_checked : rotationDot_23_8.ExtendedCheck nodes 3 := by decide
def rotationDot_23_9 : DotRecipe where
  left := fun i => #[13,12,11][i]?.getD 0
  right := fun i => #[11,14,11][i]?.getD 0
  product := fun i => #[11,2480,11][i]?.getD 0
  accumulator := fun i => #[11,11,2480,2480][i]?.getD 0
theorem rotationDot_23_9_checked : rotationDot_23_9.ExtendedCheck nodes 3 := by decide
def rotationDot_23_10 : DotRecipe where
  left := fun i => #[13,12,11][i]?.getD 0
  right := fun i => #[488,11,0][i]?.getD 0
  product := fun i => #[2482,11,11][i]?.getD 0
  accumulator := fun i => #[11,2482,2482,2482][i]?.getD 0
theorem rotationDot_23_10_checked : rotationDot_23_10.ExtendedCheck nodes 3 := by decide
def rotationDot_23_11 : DotRecipe where
  left := fun i => #[13,12,11][i]?.getD 0
  right := fun i => #[11,20,11][i]?.getD 0
  product := fun i => #[11,2467,11][i]?.getD 0
  accumulator := fun i => #[11,11,2467,2467][i]?.getD 0
theorem rotationDot_23_11_checked : rotationDot_23_11.ExtendedCheck nodes 3 := by decide
def rotationDot_23_12 : DotRecipe where
  left := fun i => #[13,12,11][i]?.getD 0
  right := fun i => #[11,14,113][i]?.getD 0
  product := fun i => #[11,2480,11][i]?.getD 0
  accumulator := fun i => #[11,11,2480,2480][i]?.getD 0
theorem rotationDot_23_12_checked : rotationDot_23_12.ExtendedCheck nodes 3 := by decide
def rotationDot_23_13 : DotRecipe where
  left := fun i => #[13,12,11][i]?.getD 0
  right := fun i => #[488,11,15][i]?.getD 0
  product := fun i => #[2482,11,11][i]?.getD 0
  accumulator := fun i => #[11,2482,2482,2482][i]?.getD 0
theorem rotationDot_23_13_checked : rotationDot_23_13.ExtendedCheck nodes 3 := by decide
def rotationDot_23_14 : DotRecipe where
  left := fun i => #[13,12,11][i]?.getD 0
  right := fun i => #[16,111,11][i]?.getD 0
  product := fun i => #[2471,2472,11][i]?.getD 0
  accumulator := fun i => #[11,2471,2473,2473][i]?.getD 0
theorem rotationDot_23_14_checked : rotationDot_23_14.ExtendedCheck nodes 3 := by decide
def rotationDot_23_15 : DotRecipe where
  left := fun i => #[13,12,11][i]?.getD 0
  right := fun i => #[11,14,265][i]?.getD 0
  product := fun i => #[11,2480,11][i]?.getD 0
  accumulator := fun i => #[11,11,2480,2480][i]?.getD 0
theorem rotationDot_23_15_checked : rotationDot_23_15.ExtendedCheck nodes 3 := by decide
def rotationDot_23_16 : DotRecipe where
  left := fun i => #[13,12,11][i]?.getD 0
  right := fun i => #[488,11,15][i]?.getD 0
  product := fun i => #[2482,11,11][i]?.getD 0
  accumulator := fun i => #[11,2482,2482,2482][i]?.getD 0
theorem rotationDot_23_16_checked : rotationDot_23_16.ExtendedCheck nodes 3 := by decide
def rotationDot_23_17 : DotRecipe where
  left := fun i => #[13,12,11][i]?.getD 0
  right := fun i => #[17,111,11][i]?.getD 0
  product := fun i => #[2477,2472,11][i]?.getD 0
  accumulator := fun i => #[11,2477,2478,2478][i]?.getD 0
theorem rotationDot_23_17_checked : rotationDot_23_17.ExtendedCheck nodes 3 := by decide
def rotationDot_23_18 : DotRecipe where
  left := fun i => #[13,12,11][i]?.getD 0
  right := fun i => #[11,11,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_23_18_checked : rotationDot_23_18.ExtendedCheck nodes 3 := by decide
def rotationDot_23_19 : DotRecipe where
  left := fun i => #[13,12,11][i]?.getD 0
  right := fun i => #[11,11,18][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_23_19_checked : rotationDot_23_19.ExtendedCheck nodes 3 := by decide
def rotationDot_23_20 : DotRecipe where
  left := fun i => #[13,12,11][i]?.getD 0
  right := fun i => #[11,2,11][i]?.getD 0
  product := fun i => #[11,12,11][i]?.getD 0
  accumulator := fun i => #[11,11,12,12][i]?.getD 0
theorem rotationDot_23_20_checked : rotationDot_23_20.ExtendedCheck nodes 3 := by decide
def rotationDot_23_21 : DotRecipe where
  left := fun i => #[13,12,11][i]?.getD 0
  right := fun i => #[11,11,19][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_23_21_checked : rotationDot_23_21.ExtendedCheck nodes 3 := by decide
def rotationDot_23_22 : DotRecipe where
  left := fun i => #[13,12,11][i]?.getD 0
  right := fun i => #[11,11,9][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_23_22_checked : rotationDot_23_22.ExtendedCheck nodes 3 := by decide
def rotationDot_23_23 : DotRecipe where
  left := fun i => #[13,12,11][i]?.getD 0
  right := fun i => #[13,12,11][i]?.getD 0
  product := fun i => #[1118,2459,11][i]?.getD 0
  accumulator := fun i => #[11,1118,2491,2491][i]?.getD 0
theorem rotationDot_23_23_checked : rotationDot_23_23.ExtendedCheck nodes 3 := by decide
def rotationDot_23_24 : DotRecipe where
  left := fun i => #[13,12,11][i]?.getD 0
  right := fun i => #[11,11,1926][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_23_24_checked : rotationDot_23_24.ExtendedCheck nodes 3 := by decide
def rotationDot_23_25 : DotRecipe where
  left := fun i => #[13,12,11][i]?.getD 0
  right := fun i => #[11,11,9][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_23_25_checked : rotationDot_23_25.ExtendedCheck nodes 3 := by decide
def rotationDot_23_26 : DotRecipe where
  left := fun i => #[13,12,11][i]?.getD 0
  right := fun i => #[19,12,11][i]?.getD 0
  product := fun i => #[2493,2459,11][i]?.getD 0
  accumulator := fun i => #[11,2493,2494,2494][i]?.getD 0
theorem rotationDot_23_26_checked : rotationDot_23_26.ExtendedCheck nodes 3 := by decide
def rotationDotsRow23 : Array DotRecipe := #[rotationDot_23_0,rotationDot_23_1,rotationDot_23_2,rotationDot_23_3,rotationDot_23_4,rotationDot_23_5,rotationDot_23_6,rotationDot_23_7,rotationDot_23_8,rotationDot_23_9,rotationDot_23_10,rotationDot_23_11,rotationDot_23_12,rotationDot_23_13,rotationDot_23_14,rotationDot_23_15,rotationDot_23_16,rotationDot_23_17,rotationDot_23_18,rotationDot_23_19,rotationDot_23_20,rotationDot_23_21,rotationDot_23_22,rotationDot_23_23,rotationDot_23_24,rotationDot_23_25,rotationDot_23_26]
theorem rotationDotsRow23_checked (j : Fin 27) :
    (rotationDotsRow23[j.val]?.getD rotationDot_0_0).ExtendedCheck nodes 3 := by
  fin_cases j
  · exact rotationDot_23_0_checked
  · exact rotationDot_23_1_checked
  · exact rotationDot_23_2_checked
  · exact rotationDot_23_3_checked
  · exact rotationDot_23_4_checked
  · exact rotationDot_23_5_checked
  · exact rotationDot_23_6_checked
  · exact rotationDot_23_7_checked
  · exact rotationDot_23_8_checked
  · exact rotationDot_23_9_checked
  · exact rotationDot_23_10_checked
  · exact rotationDot_23_11_checked
  · exact rotationDot_23_12_checked
  · exact rotationDot_23_13_checked
  · exact rotationDot_23_14_checked
  · exact rotationDot_23_15_checked
  · exact rotationDot_23_16_checked
  · exact rotationDot_23_17_checked
  · exact rotationDot_23_18_checked
  · exact rotationDot_23_19_checked
  · exact rotationDot_23_20_checked
  · exact rotationDot_23_21_checked
  · exact rotationDot_23_22_checked
  · exact rotationDot_23_23_checked
  · exact rotationDot_23_24_checked
  · exact rotationDot_23_25_checked
  · exact rotationDot_23_26_checked
def rotationDot_24_0 : DotRecipe where
  left := fun i => #[11,11,1926][i]?.getD 0
  right := fun i => #[11,5,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_24_0_checked : rotationDot_24_0.ExtendedCheck nodes 3 := by decide
def rotationDot_24_1 : DotRecipe where
  left := fun i => #[11,11,1926][i]?.getD 0
  right := fun i => #[14,11,0][i]?.getD 0
  product := fun i => #[11,11,2496][i]?.getD 0
  accumulator := fun i => #[11,11,11,2496][i]?.getD 0
theorem rotationDot_24_1_checked : rotationDot_24_1.ExtendedCheck nodes 3 := by decide
def rotationDot_24_2 : DotRecipe where
  left := fun i => #[11,11,1926][i]?.getD 0
  right := fun i => #[11,20,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_24_2_checked : rotationDot_24_2.ExtendedCheck nodes 3 := by decide
def rotationDot_24_3 : DotRecipe where
  left := fun i => #[11,11,1926][i]?.getD 0
  right := fun i => #[11,5,113][i]?.getD 0
  product := fun i => #[11,11,2498][i]?.getD 0
  accumulator := fun i => #[11,11,11,2498][i]?.getD 0
theorem rotationDot_24_3_checked : rotationDot_24_3.ExtendedCheck nodes 3 := by decide
def rotationDot_24_4 : DotRecipe where
  left := fun i => #[11,11,1926][i]?.getD 0
  right := fun i => #[14,11,15][i]?.getD 0
  product := fun i => #[11,11,2500][i]?.getD 0
  accumulator := fun i => #[11,11,11,2500][i]?.getD 0
theorem rotationDot_24_4_checked : rotationDot_24_4.ExtendedCheck nodes 3 := by decide
def rotationDot_24_5 : DotRecipe where
  left := fun i => #[11,11,1926][i]?.getD 0
  right := fun i => #[16,111,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_24_5_checked : rotationDot_24_5.ExtendedCheck nodes 3 := by decide
def rotationDot_24_6 : DotRecipe where
  left := fun i => #[11,11,1926][i]?.getD 0
  right := fun i => #[11,5,265][i]?.getD 0
  product := fun i => #[11,11,2502][i]?.getD 0
  accumulator := fun i => #[11,11,11,2502][i]?.getD 0
theorem rotationDot_24_6_checked : rotationDot_24_6.ExtendedCheck nodes 3 := by decide
def rotationDot_24_7 : DotRecipe where
  left := fun i => #[11,11,1926][i]?.getD 0
  right := fun i => #[14,11,15][i]?.getD 0
  product := fun i => #[11,11,2500][i]?.getD 0
  accumulator := fun i => #[11,11,11,2500][i]?.getD 0
theorem rotationDot_24_7_checked : rotationDot_24_7.ExtendedCheck nodes 3 := by decide
def rotationDot_24_8 : DotRecipe where
  left := fun i => #[11,11,1926][i]?.getD 0
  right := fun i => #[17,111,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_24_8_checked : rotationDot_24_8.ExtendedCheck nodes 3 := by decide
def rotationDot_24_9 : DotRecipe where
  left := fun i => #[11,11,1926][i]?.getD 0
  right := fun i => #[11,14,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_24_9_checked : rotationDot_24_9.ExtendedCheck nodes 3 := by decide
def rotationDot_24_10 : DotRecipe where
  left := fun i => #[11,11,1926][i]?.getD 0
  right := fun i => #[488,11,0][i]?.getD 0
  product := fun i => #[11,11,2496][i]?.getD 0
  accumulator := fun i => #[11,11,11,2496][i]?.getD 0
theorem rotationDot_24_10_checked : rotationDot_24_10.ExtendedCheck nodes 3 := by decide
def rotationDot_24_11 : DotRecipe where
  left := fun i => #[11,11,1926][i]?.getD 0
  right := fun i => #[11,20,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_24_11_checked : rotationDot_24_11.ExtendedCheck nodes 3 := by decide
def rotationDot_24_12 : DotRecipe where
  left := fun i => #[11,11,1926][i]?.getD 0
  right := fun i => #[11,14,113][i]?.getD 0
  product := fun i => #[11,11,2498][i]?.getD 0
  accumulator := fun i => #[11,11,11,2498][i]?.getD 0
theorem rotationDot_24_12_checked : rotationDot_24_12.ExtendedCheck nodes 3 := by decide
def rotationDot_24_13 : DotRecipe where
  left := fun i => #[11,11,1926][i]?.getD 0
  right := fun i => #[488,11,15][i]?.getD 0
  product := fun i => #[11,11,2500][i]?.getD 0
  accumulator := fun i => #[11,11,11,2500][i]?.getD 0
theorem rotationDot_24_13_checked : rotationDot_24_13.ExtendedCheck nodes 3 := by decide
def rotationDot_24_14 : DotRecipe where
  left := fun i => #[11,11,1926][i]?.getD 0
  right := fun i => #[16,111,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_24_14_checked : rotationDot_24_14.ExtendedCheck nodes 3 := by decide
def rotationDot_24_15 : DotRecipe where
  left := fun i => #[11,11,1926][i]?.getD 0
  right := fun i => #[11,14,265][i]?.getD 0
  product := fun i => #[11,11,2502][i]?.getD 0
  accumulator := fun i => #[11,11,11,2502][i]?.getD 0
theorem rotationDot_24_15_checked : rotationDot_24_15.ExtendedCheck nodes 3 := by decide
def rotationDot_24_16 : DotRecipe where
  left := fun i => #[11,11,1926][i]?.getD 0
  right := fun i => #[488,11,15][i]?.getD 0
  product := fun i => #[11,11,2500][i]?.getD 0
  accumulator := fun i => #[11,11,11,2500][i]?.getD 0
theorem rotationDot_24_16_checked : rotationDot_24_16.ExtendedCheck nodes 3 := by decide
def rotationDot_24_17 : DotRecipe where
  left := fun i => #[11,11,1926][i]?.getD 0
  right := fun i => #[17,111,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_24_17_checked : rotationDot_24_17.ExtendedCheck nodes 3 := by decide
def rotationDot_24_18 : DotRecipe where
  left := fun i => #[11,11,1926][i]?.getD 0
  right := fun i => #[11,11,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_24_18_checked : rotationDot_24_18.ExtendedCheck nodes 3 := by decide
def rotationDot_24_19 : DotRecipe where
  left := fun i => #[11,11,1926][i]?.getD 0
  right := fun i => #[11,11,18][i]?.getD 0
  product := fun i => #[11,11,2510][i]?.getD 0
  accumulator := fun i => #[11,11,11,2510][i]?.getD 0
theorem rotationDot_24_19_checked : rotationDot_24_19.ExtendedCheck nodes 3 := by decide
def rotationDot_24_20 : DotRecipe where
  left := fun i => #[11,11,1926][i]?.getD 0
  right := fun i => #[11,2,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_24_20_checked : rotationDot_24_20.ExtendedCheck nodes 3 := by decide
def rotationDot_24_21 : DotRecipe where
  left := fun i => #[11,11,1926][i]?.getD 0
  right := fun i => #[11,11,19][i]?.getD 0
  product := fun i => #[11,11,2512][i]?.getD 0
  accumulator := fun i => #[11,11,11,2512][i]?.getD 0
theorem rotationDot_24_21_checked : rotationDot_24_21.ExtendedCheck nodes 3 := by decide
def rotationDot_24_22 : DotRecipe where
  left := fun i => #[11,11,1926][i]?.getD 0
  right := fun i => #[11,11,9][i]?.getD 0
  product := fun i => #[11,11,2514][i]?.getD 0
  accumulator := fun i => #[11,11,11,2514][i]?.getD 0
theorem rotationDot_24_22_checked : rotationDot_24_22.ExtendedCheck nodes 3 := by decide
def rotationDot_24_23 : DotRecipe where
  left := fun i => #[11,11,1926][i]?.getD 0
  right := fun i => #[13,12,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_24_23_checked : rotationDot_24_23.ExtendedCheck nodes 3 := by decide
def rotationDot_24_24 : DotRecipe where
  left := fun i => #[11,11,1926][i]?.getD 0
  right := fun i => #[11,11,1926][i]?.getD 0
  product := fun i => #[11,11,2515][i]?.getD 0
  accumulator := fun i => #[11,11,11,2515][i]?.getD 0
theorem rotationDot_24_24_checked : rotationDot_24_24.ExtendedCheck nodes 3 := by decide
def rotationDot_24_25 : DotRecipe where
  left := fun i => #[11,11,1926][i]?.getD 0
  right := fun i => #[11,11,9][i]?.getD 0
  product := fun i => #[11,11,2514][i]?.getD 0
  accumulator := fun i => #[11,11,11,2514][i]?.getD 0
theorem rotationDot_24_25_checked : rotationDot_24_25.ExtendedCheck nodes 3 := by decide
def rotationDot_24_26 : DotRecipe where
  left := fun i => #[11,11,1926][i]?.getD 0
  right := fun i => #[19,12,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_24_26_checked : rotationDot_24_26.ExtendedCheck nodes 3 := by decide
def rotationDotsRow24 : Array DotRecipe := #[rotationDot_24_0,rotationDot_24_1,rotationDot_24_2,rotationDot_24_3,rotationDot_24_4,rotationDot_24_5,rotationDot_24_6,rotationDot_24_7,rotationDot_24_8,rotationDot_24_9,rotationDot_24_10,rotationDot_24_11,rotationDot_24_12,rotationDot_24_13,rotationDot_24_14,rotationDot_24_15,rotationDot_24_16,rotationDot_24_17,rotationDot_24_18,rotationDot_24_19,rotationDot_24_20,rotationDot_24_21,rotationDot_24_22,rotationDot_24_23,rotationDot_24_24,rotationDot_24_25,rotationDot_24_26]
theorem rotationDotsRow24_checked (j : Fin 27) :
    (rotationDotsRow24[j.val]?.getD rotationDot_0_0).ExtendedCheck nodes 3 := by
  fin_cases j
  · exact rotationDot_24_0_checked
  · exact rotationDot_24_1_checked
  · exact rotationDot_24_2_checked
  · exact rotationDot_24_3_checked
  · exact rotationDot_24_4_checked
  · exact rotationDot_24_5_checked
  · exact rotationDot_24_6_checked
  · exact rotationDot_24_7_checked
  · exact rotationDot_24_8_checked
  · exact rotationDot_24_9_checked
  · exact rotationDot_24_10_checked
  · exact rotationDot_24_11_checked
  · exact rotationDot_24_12_checked
  · exact rotationDot_24_13_checked
  · exact rotationDot_24_14_checked
  · exact rotationDot_24_15_checked
  · exact rotationDot_24_16_checked
  · exact rotationDot_24_17_checked
  · exact rotationDot_24_18_checked
  · exact rotationDot_24_19_checked
  · exact rotationDot_24_20_checked
  · exact rotationDot_24_21_checked
  · exact rotationDot_24_22_checked
  · exact rotationDot_24_23_checked
  · exact rotationDot_24_24_checked
  · exact rotationDot_24_25_checked
  · exact rotationDot_24_26_checked
def rotationDot_25_0 : DotRecipe where
  left := fun i => #[11,11,9][i]?.getD 0
  right := fun i => #[11,5,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_25_0_checked : rotationDot_25_0.ExtendedCheck nodes 3 := by decide
def rotationDot_25_1 : DotRecipe where
  left := fun i => #[11,11,9][i]?.getD 0
  right := fun i => #[14,11,0][i]?.getD 0
  product := fun i => #[11,11,2443][i]?.getD 0
  accumulator := fun i => #[11,11,11,2443][i]?.getD 0
theorem rotationDot_25_1_checked : rotationDot_25_1.ExtendedCheck nodes 3 := by decide
def rotationDot_25_2 : DotRecipe where
  left := fun i => #[11,11,9][i]?.getD 0
  right := fun i => #[11,20,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_25_2_checked : rotationDot_25_2.ExtendedCheck nodes 3 := by decide
def rotationDot_25_3 : DotRecipe where
  left := fun i => #[11,11,9][i]?.getD 0
  right := fun i => #[11,5,113][i]?.getD 0
  product := fun i => #[11,11,2445][i]?.getD 0
  accumulator := fun i => #[11,11,11,2445][i]?.getD 0
theorem rotationDot_25_3_checked : rotationDot_25_3.ExtendedCheck nodes 3 := by decide
def rotationDot_25_4 : DotRecipe where
  left := fun i => #[11,11,9][i]?.getD 0
  right := fun i => #[14,11,15][i]?.getD 0
  product := fun i => #[11,11,2447][i]?.getD 0
  accumulator := fun i => #[11,11,11,2447][i]?.getD 0
theorem rotationDot_25_4_checked : rotationDot_25_4.ExtendedCheck nodes 3 := by decide
def rotationDot_25_5 : DotRecipe where
  left := fun i => #[11,11,9][i]?.getD 0
  right := fun i => #[16,111,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_25_5_checked : rotationDot_25_5.ExtendedCheck nodes 3 := by decide
def rotationDot_25_6 : DotRecipe where
  left := fun i => #[11,11,9][i]?.getD 0
  right := fun i => #[11,5,265][i]?.getD 0
  product := fun i => #[11,11,2449][i]?.getD 0
  accumulator := fun i => #[11,11,11,2449][i]?.getD 0
theorem rotationDot_25_6_checked : rotationDot_25_6.ExtendedCheck nodes 3 := by decide
def rotationDot_25_7 : DotRecipe where
  left := fun i => #[11,11,9][i]?.getD 0
  right := fun i => #[14,11,15][i]?.getD 0
  product := fun i => #[11,11,2447][i]?.getD 0
  accumulator := fun i => #[11,11,11,2447][i]?.getD 0
theorem rotationDot_25_7_checked : rotationDot_25_7.ExtendedCheck nodes 3 := by decide
def rotationDot_25_8 : DotRecipe where
  left := fun i => #[11,11,9][i]?.getD 0
  right := fun i => #[17,111,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_25_8_checked : rotationDot_25_8.ExtendedCheck nodes 3 := by decide
def rotationDot_25_9 : DotRecipe where
  left := fun i => #[11,11,9][i]?.getD 0
  right := fun i => #[11,14,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_25_9_checked : rotationDot_25_9.ExtendedCheck nodes 3 := by decide
def rotationDot_25_10 : DotRecipe where
  left := fun i => #[11,11,9][i]?.getD 0
  right := fun i => #[488,11,0][i]?.getD 0
  product := fun i => #[11,11,2443][i]?.getD 0
  accumulator := fun i => #[11,11,11,2443][i]?.getD 0
theorem rotationDot_25_10_checked : rotationDot_25_10.ExtendedCheck nodes 3 := by decide
def rotationDot_25_11 : DotRecipe where
  left := fun i => #[11,11,9][i]?.getD 0
  right := fun i => #[11,20,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_25_11_checked : rotationDot_25_11.ExtendedCheck nodes 3 := by decide
def rotationDot_25_12 : DotRecipe where
  left := fun i => #[11,11,9][i]?.getD 0
  right := fun i => #[11,14,113][i]?.getD 0
  product := fun i => #[11,11,2445][i]?.getD 0
  accumulator := fun i => #[11,11,11,2445][i]?.getD 0
theorem rotationDot_25_12_checked : rotationDot_25_12.ExtendedCheck nodes 3 := by decide
def rotationDot_25_13 : DotRecipe where
  left := fun i => #[11,11,9][i]?.getD 0
  right := fun i => #[488,11,15][i]?.getD 0
  product := fun i => #[11,11,2447][i]?.getD 0
  accumulator := fun i => #[11,11,11,2447][i]?.getD 0
theorem rotationDot_25_13_checked : rotationDot_25_13.ExtendedCheck nodes 3 := by decide
def rotationDot_25_14 : DotRecipe where
  left := fun i => #[11,11,9][i]?.getD 0
  right := fun i => #[16,111,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_25_14_checked : rotationDot_25_14.ExtendedCheck nodes 3 := by decide
def rotationDot_25_15 : DotRecipe where
  left := fun i => #[11,11,9][i]?.getD 0
  right := fun i => #[11,14,265][i]?.getD 0
  product := fun i => #[11,11,2449][i]?.getD 0
  accumulator := fun i => #[11,11,11,2449][i]?.getD 0
theorem rotationDot_25_15_checked : rotationDot_25_15.ExtendedCheck nodes 3 := by decide
def rotationDot_25_16 : DotRecipe where
  left := fun i => #[11,11,9][i]?.getD 0
  right := fun i => #[488,11,15][i]?.getD 0
  product := fun i => #[11,11,2447][i]?.getD 0
  accumulator := fun i => #[11,11,11,2447][i]?.getD 0
theorem rotationDot_25_16_checked : rotationDot_25_16.ExtendedCheck nodes 3 := by decide
def rotationDot_25_17 : DotRecipe where
  left := fun i => #[11,11,9][i]?.getD 0
  right := fun i => #[17,111,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_25_17_checked : rotationDot_25_17.ExtendedCheck nodes 3 := by decide
def rotationDot_25_18 : DotRecipe where
  left := fun i => #[11,11,9][i]?.getD 0
  right := fun i => #[11,11,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_25_18_checked : rotationDot_25_18.ExtendedCheck nodes 3 := by decide
def rotationDot_25_19 : DotRecipe where
  left := fun i => #[11,11,9][i]?.getD 0
  right := fun i => #[11,11,18][i]?.getD 0
  product := fun i => #[11,11,12][i]?.getD 0
  accumulator := fun i => #[11,11,11,12][i]?.getD 0
theorem rotationDot_25_19_checked : rotationDot_25_19.ExtendedCheck nodes 3 := by decide
def rotationDot_25_20 : DotRecipe where
  left := fun i => #[11,11,9][i]?.getD 0
  right := fun i => #[11,2,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_25_20_checked : rotationDot_25_20.ExtendedCheck nodes 3 := by decide
def rotationDot_25_21 : DotRecipe where
  left := fun i => #[11,11,9][i]?.getD 0
  right := fun i => #[11,11,19][i]?.getD 0
  product := fun i => #[11,11,2457][i]?.getD 0
  accumulator := fun i => #[11,11,11,2457][i]?.getD 0
theorem rotationDot_25_21_checked : rotationDot_25_21.ExtendedCheck nodes 3 := by decide
def rotationDot_25_22 : DotRecipe where
  left := fun i => #[11,11,9][i]?.getD 0
  right := fun i => #[11,11,9][i]?.getD 0
  product := fun i => #[11,11,2459][i]?.getD 0
  accumulator := fun i => #[11,11,11,2459][i]?.getD 0
theorem rotationDot_25_22_checked : rotationDot_25_22.ExtendedCheck nodes 3 := by decide
def rotationDot_25_23 : DotRecipe where
  left := fun i => #[11,11,9][i]?.getD 0
  right := fun i => #[13,12,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_25_23_checked : rotationDot_25_23.ExtendedCheck nodes 3 := by decide
def rotationDot_25_24 : DotRecipe where
  left := fun i => #[11,11,9][i]?.getD 0
  right := fun i => #[11,11,1926][i]?.getD 0
  product := fun i => #[11,11,2461][i]?.getD 0
  accumulator := fun i => #[11,11,11,2461][i]?.getD 0
theorem rotationDot_25_24_checked : rotationDot_25_24.ExtendedCheck nodes 3 := by decide
def rotationDot_25_25 : DotRecipe where
  left := fun i => #[11,11,9][i]?.getD 0
  right := fun i => #[11,11,9][i]?.getD 0
  product := fun i => #[11,11,2459][i]?.getD 0
  accumulator := fun i => #[11,11,11,2459][i]?.getD 0
theorem rotationDot_25_25_checked : rotationDot_25_25.ExtendedCheck nodes 3 := by decide
def rotationDot_25_26 : DotRecipe where
  left := fun i => #[11,11,9][i]?.getD 0
  right := fun i => #[19,12,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_25_26_checked : rotationDot_25_26.ExtendedCheck nodes 3 := by decide
def rotationDotsRow25 : Array DotRecipe := #[rotationDot_25_0,rotationDot_25_1,rotationDot_25_2,rotationDot_25_3,rotationDot_25_4,rotationDot_25_5,rotationDot_25_6,rotationDot_25_7,rotationDot_25_8,rotationDot_25_9,rotationDot_25_10,rotationDot_25_11,rotationDot_25_12,rotationDot_25_13,rotationDot_25_14,rotationDot_25_15,rotationDot_25_16,rotationDot_25_17,rotationDot_25_18,rotationDot_25_19,rotationDot_25_20,rotationDot_25_21,rotationDot_25_22,rotationDot_25_23,rotationDot_25_24,rotationDot_25_25,rotationDot_25_26]
theorem rotationDotsRow25_checked (j : Fin 27) :
    (rotationDotsRow25[j.val]?.getD rotationDot_0_0).ExtendedCheck nodes 3 := by
  fin_cases j
  · exact rotationDot_25_0_checked
  · exact rotationDot_25_1_checked
  · exact rotationDot_25_2_checked
  · exact rotationDot_25_3_checked
  · exact rotationDot_25_4_checked
  · exact rotationDot_25_5_checked
  · exact rotationDot_25_6_checked
  · exact rotationDot_25_7_checked
  · exact rotationDot_25_8_checked
  · exact rotationDot_25_9_checked
  · exact rotationDot_25_10_checked
  · exact rotationDot_25_11_checked
  · exact rotationDot_25_12_checked
  · exact rotationDot_25_13_checked
  · exact rotationDot_25_14_checked
  · exact rotationDot_25_15_checked
  · exact rotationDot_25_16_checked
  · exact rotationDot_25_17_checked
  · exact rotationDot_25_18_checked
  · exact rotationDot_25_19_checked
  · exact rotationDot_25_20_checked
  · exact rotationDot_25_21_checked
  · exact rotationDot_25_22_checked
  · exact rotationDot_25_23_checked
  · exact rotationDot_25_24_checked
  · exact rotationDot_25_25_checked
  · exact rotationDot_25_26_checked
def rotationDot_26_0 : DotRecipe where
  left := fun i => #[19,12,11][i]?.getD 0
  right := fun i => #[11,5,11][i]?.getD 0
  product := fun i => #[11,2463,11][i]?.getD 0
  accumulator := fun i => #[11,11,2463,2463][i]?.getD 0
theorem rotationDot_26_0_checked : rotationDot_26_0.ExtendedCheck nodes 3 := by decide
def rotationDot_26_1 : DotRecipe where
  left := fun i => #[19,12,11][i]?.getD 0
  right := fun i => #[14,11,0][i]?.getD 0
  product := fun i => #[2531,11,11][i]?.getD 0
  accumulator := fun i => #[11,2531,2531,2531][i]?.getD 0
theorem rotationDot_26_1_checked : rotationDot_26_1.ExtendedCheck nodes 3 := by decide
def rotationDot_26_2 : DotRecipe where
  left := fun i => #[19,12,11][i]?.getD 0
  right := fun i => #[11,20,11][i]?.getD 0
  product := fun i => #[11,2467,11][i]?.getD 0
  accumulator := fun i => #[11,11,2467,2467][i]?.getD 0
theorem rotationDot_26_2_checked : rotationDot_26_2.ExtendedCheck nodes 3 := by decide
def rotationDot_26_3 : DotRecipe where
  left := fun i => #[19,12,11][i]?.getD 0
  right := fun i => #[11,5,113][i]?.getD 0
  product := fun i => #[11,2463,11][i]?.getD 0
  accumulator := fun i => #[11,11,2463,2463][i]?.getD 0
theorem rotationDot_26_3_checked : rotationDot_26_3.ExtendedCheck nodes 3 := by decide
def rotationDot_26_4 : DotRecipe where
  left := fun i => #[19,12,11][i]?.getD 0
  right := fun i => #[14,11,15][i]?.getD 0
  product := fun i => #[2531,11,11][i]?.getD 0
  accumulator := fun i => #[11,2531,2531,2531][i]?.getD 0
theorem rotationDot_26_4_checked : rotationDot_26_4.ExtendedCheck nodes 3 := by decide
def rotationDot_26_5 : DotRecipe where
  left := fun i => #[19,12,11][i]?.getD 0
  right := fun i => #[16,111,11][i]?.getD 0
  product := fun i => #[2536,2472,11][i]?.getD 0
  accumulator := fun i => #[11,2536,2537,2537][i]?.getD 0
theorem rotationDot_26_5_checked : rotationDot_26_5.ExtendedCheck nodes 3 := by decide
def rotationDot_26_6 : DotRecipe where
  left := fun i => #[19,12,11][i]?.getD 0
  right := fun i => #[11,5,265][i]?.getD 0
  product := fun i => #[11,2463,11][i]?.getD 0
  accumulator := fun i => #[11,11,2463,2463][i]?.getD 0
theorem rotationDot_26_6_checked : rotationDot_26_6.ExtendedCheck nodes 3 := by decide
def rotationDot_26_7 : DotRecipe where
  left := fun i => #[19,12,11][i]?.getD 0
  right := fun i => #[14,11,15][i]?.getD 0
  product := fun i => #[2531,11,11][i]?.getD 0
  accumulator := fun i => #[11,2531,2531,2531][i]?.getD 0
theorem rotationDot_26_7_checked : rotationDot_26_7.ExtendedCheck nodes 3 := by decide
def rotationDot_26_8 : DotRecipe where
  left := fun i => #[19,12,11][i]?.getD 0
  right := fun i => #[17,111,11][i]?.getD 0
  product := fun i => #[2541,2472,11][i]?.getD 0
  accumulator := fun i => #[11,2541,2542,2542][i]?.getD 0
theorem rotationDot_26_8_checked : rotationDot_26_8.ExtendedCheck nodes 3 := by decide
def rotationDot_26_9 : DotRecipe where
  left := fun i => #[19,12,11][i]?.getD 0
  right := fun i => #[11,14,11][i]?.getD 0
  product := fun i => #[11,2480,11][i]?.getD 0
  accumulator := fun i => #[11,11,2480,2480][i]?.getD 0
theorem rotationDot_26_9_checked : rotationDot_26_9.ExtendedCheck nodes 3 := by decide
def rotationDot_26_10 : DotRecipe where
  left := fun i => #[19,12,11][i]?.getD 0
  right := fun i => #[488,11,0][i]?.getD 0
  product := fun i => #[2545,11,11][i]?.getD 0
  accumulator := fun i => #[11,2545,2545,2545][i]?.getD 0
theorem rotationDot_26_10_checked : rotationDot_26_10.ExtendedCheck nodes 3 := by decide
def rotationDot_26_11 : DotRecipe where
  left := fun i => #[19,12,11][i]?.getD 0
  right := fun i => #[11,20,11][i]?.getD 0
  product := fun i => #[11,2467,11][i]?.getD 0
  accumulator := fun i => #[11,11,2467,2467][i]?.getD 0
theorem rotationDot_26_11_checked : rotationDot_26_11.ExtendedCheck nodes 3 := by decide
def rotationDot_26_12 : DotRecipe where
  left := fun i => #[19,12,11][i]?.getD 0
  right := fun i => #[11,14,113][i]?.getD 0
  product := fun i => #[11,2480,11][i]?.getD 0
  accumulator := fun i => #[11,11,2480,2480][i]?.getD 0
theorem rotationDot_26_12_checked : rotationDot_26_12.ExtendedCheck nodes 3 := by decide
def rotationDot_26_13 : DotRecipe where
  left := fun i => #[19,12,11][i]?.getD 0
  right := fun i => #[488,11,15][i]?.getD 0
  product := fun i => #[2545,11,11][i]?.getD 0
  accumulator := fun i => #[11,2545,2545,2545][i]?.getD 0
theorem rotationDot_26_13_checked : rotationDot_26_13.ExtendedCheck nodes 3 := by decide
def rotationDot_26_14 : DotRecipe where
  left := fun i => #[19,12,11][i]?.getD 0
  right := fun i => #[16,111,11][i]?.getD 0
  product := fun i => #[2536,2472,11][i]?.getD 0
  accumulator := fun i => #[11,2536,2537,2537][i]?.getD 0
theorem rotationDot_26_14_checked : rotationDot_26_14.ExtendedCheck nodes 3 := by decide
def rotationDot_26_15 : DotRecipe where
  left := fun i => #[19,12,11][i]?.getD 0
  right := fun i => #[11,14,265][i]?.getD 0
  product := fun i => #[11,2480,11][i]?.getD 0
  accumulator := fun i => #[11,11,2480,2480][i]?.getD 0
theorem rotationDot_26_15_checked : rotationDot_26_15.ExtendedCheck nodes 3 := by decide
def rotationDot_26_16 : DotRecipe where
  left := fun i => #[19,12,11][i]?.getD 0
  right := fun i => #[488,11,15][i]?.getD 0
  product := fun i => #[2545,11,11][i]?.getD 0
  accumulator := fun i => #[11,2545,2545,2545][i]?.getD 0
theorem rotationDot_26_16_checked : rotationDot_26_16.ExtendedCheck nodes 3 := by decide
def rotationDot_26_17 : DotRecipe where
  left := fun i => #[19,12,11][i]?.getD 0
  right := fun i => #[17,111,11][i]?.getD 0
  product := fun i => #[2541,2472,11][i]?.getD 0
  accumulator := fun i => #[11,2541,2542,2542][i]?.getD 0
theorem rotationDot_26_17_checked : rotationDot_26_17.ExtendedCheck nodes 3 := by decide
def rotationDot_26_18 : DotRecipe where
  left := fun i => #[19,12,11][i]?.getD 0
  right := fun i => #[11,11,11][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_26_18_checked : rotationDot_26_18.ExtendedCheck nodes 3 := by decide
def rotationDot_26_19 : DotRecipe where
  left := fun i => #[19,12,11][i]?.getD 0
  right := fun i => #[11,11,18][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_26_19_checked : rotationDot_26_19.ExtendedCheck nodes 3 := by decide
def rotationDot_26_20 : DotRecipe where
  left := fun i => #[19,12,11][i]?.getD 0
  right := fun i => #[11,2,11][i]?.getD 0
  product := fun i => #[11,12,11][i]?.getD 0
  accumulator := fun i => #[11,11,12,12][i]?.getD 0
theorem rotationDot_26_20_checked : rotationDot_26_20.ExtendedCheck nodes 3 := by decide
def rotationDot_26_21 : DotRecipe where
  left := fun i => #[19,12,11][i]?.getD 0
  right := fun i => #[11,11,19][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_26_21_checked : rotationDot_26_21.ExtendedCheck nodes 3 := by decide
def rotationDot_26_22 : DotRecipe where
  left := fun i => #[19,12,11][i]?.getD 0
  right := fun i => #[11,11,9][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_26_22_checked : rotationDot_26_22.ExtendedCheck nodes 3 := by decide
def rotationDot_26_23 : DotRecipe where
  left := fun i => #[19,12,11][i]?.getD 0
  right := fun i => #[13,12,11][i]?.getD 0
  product := fun i => #[2554,2459,11][i]?.getD 0
  accumulator := fun i => #[11,2554,2555,2555][i]?.getD 0
theorem rotationDot_26_23_checked : rotationDot_26_23.ExtendedCheck nodes 3 := by decide
def rotationDot_26_24 : DotRecipe where
  left := fun i => #[19,12,11][i]?.getD 0
  right := fun i => #[11,11,1926][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_26_24_checked : rotationDot_26_24.ExtendedCheck nodes 3 := by decide
def rotationDot_26_25 : DotRecipe where
  left := fun i => #[19,12,11][i]?.getD 0
  right := fun i => #[11,11,9][i]?.getD 0
  product := fun i => #[11,11,11][i]?.getD 0
  accumulator := fun i => #[11,11,11,11][i]?.getD 0
theorem rotationDot_26_25_checked : rotationDot_26_25.ExtendedCheck nodes 3 := by decide
def rotationDot_26_26 : DotRecipe where
  left := fun i => #[19,12,11][i]?.getD 0
  right := fun i => #[19,12,11][i]?.getD 0
  product := fun i => #[1493,2459,11][i]?.getD 0
  accumulator := fun i => #[11,1493,2557,2557][i]?.getD 0
theorem rotationDot_26_26_checked : rotationDot_26_26.ExtendedCheck nodes 3 := by decide
def rotationDotsRow26 : Array DotRecipe := #[rotationDot_26_0,rotationDot_26_1,rotationDot_26_2,rotationDot_26_3,rotationDot_26_4,rotationDot_26_5,rotationDot_26_6,rotationDot_26_7,rotationDot_26_8,rotationDot_26_9,rotationDot_26_10,rotationDot_26_11,rotationDot_26_12,rotationDot_26_13,rotationDot_26_14,rotationDot_26_15,rotationDot_26_16,rotationDot_26_17,rotationDot_26_18,rotationDot_26_19,rotationDot_26_20,rotationDot_26_21,rotationDot_26_22,rotationDot_26_23,rotationDot_26_24,rotationDot_26_25,rotationDot_26_26]
theorem rotationDotsRow26_checked (j : Fin 27) :
    (rotationDotsRow26[j.val]?.getD rotationDot_0_0).ExtendedCheck nodes 3 := by
  fin_cases j
  · exact rotationDot_26_0_checked
  · exact rotationDot_26_1_checked
  · exact rotationDot_26_2_checked
  · exact rotationDot_26_3_checked
  · exact rotationDot_26_4_checked
  · exact rotationDot_26_5_checked
  · exact rotationDot_26_6_checked
  · exact rotationDot_26_7_checked
  · exact rotationDot_26_8_checked
  · exact rotationDot_26_9_checked
  · exact rotationDot_26_10_checked
  · exact rotationDot_26_11_checked
  · exact rotationDot_26_12_checked
  · exact rotationDot_26_13_checked
  · exact rotationDot_26_14_checked
  · exact rotationDot_26_15_checked
  · exact rotationDot_26_16_checked
  · exact rotationDot_26_17_checked
  · exact rotationDot_26_18_checked
  · exact rotationDot_26_19_checked
  · exact rotationDot_26_20_checked
  · exact rotationDot_26_21_checked
  · exact rotationDot_26_22_checked
  · exact rotationDot_26_23_checked
  · exact rotationDot_26_24_checked
  · exact rotationDot_26_25_checked
  · exact rotationDot_26_26_checked
def rotationDots (ia jb : Fin 9 × Fin 3) : DotRecipe :=
  (#[rotationDotsRow0,rotationDotsRow1,rotationDotsRow2,rotationDotsRow3,rotationDotsRow4,rotationDotsRow5,rotationDotsRow6,rotationDotsRow7,rotationDotsRow8,rotationDotsRow9,rotationDotsRow10,rotationDotsRow11,rotationDotsRow12,rotationDotsRow13,rotationDotsRow14,rotationDotsRow15,rotationDotsRow16,rotationDotsRow17,rotationDotsRow18,rotationDotsRow19,rotationDotsRow20,rotationDotsRow21,rotationDotsRow22,rotationDotsRow23,rotationDotsRow24,rotationDotsRow25,rotationDotsRow26][flatIndex ia]?.getD #[])[flatIndex jb]?.getD rotationDot_0_0
theorem rotation_dots_checked (ia jb : Fin 9 × Fin 3) : (rotationDots ia jb).ExtendedCheck nodes 3 := by
  rcases ia with ⟨i,a⟩
  have hj : flatIndex jb < 27 := by rcases jb with ⟨j,b⟩; simp only [flatIndex]; omega
  fin_cases i <;> fin_cases a
  · exact rotationDotsRow0_checked ⟨flatIndex jb,hj⟩
  · exact rotationDotsRow1_checked ⟨flatIndex jb,hj⟩
  · exact rotationDotsRow2_checked ⟨flatIndex jb,hj⟩
  · exact rotationDotsRow3_checked ⟨flatIndex jb,hj⟩
  · exact rotationDotsRow4_checked ⟨flatIndex jb,hj⟩
  · exact rotationDotsRow5_checked ⟨flatIndex jb,hj⟩
  · exact rotationDotsRow6_checked ⟨flatIndex jb,hj⟩
  · exact rotationDotsRow7_checked ⟨flatIndex jb,hj⟩
  · exact rotationDotsRow8_checked ⟨flatIndex jb,hj⟩
  · exact rotationDotsRow9_checked ⟨flatIndex jb,hj⟩
  · exact rotationDotsRow10_checked ⟨flatIndex jb,hj⟩
  · exact rotationDotsRow11_checked ⟨flatIndex jb,hj⟩
  · exact rotationDotsRow12_checked ⟨flatIndex jb,hj⟩
  · exact rotationDotsRow13_checked ⟨flatIndex jb,hj⟩
  · exact rotationDotsRow14_checked ⟨flatIndex jb,hj⟩
  · exact rotationDotsRow15_checked ⟨flatIndex jb,hj⟩
  · exact rotationDotsRow16_checked ⟨flatIndex jb,hj⟩
  · exact rotationDotsRow17_checked ⟨flatIndex jb,hj⟩
  · exact rotationDotsRow18_checked ⟨flatIndex jb,hj⟩
  · exact rotationDotsRow19_checked ⟨flatIndex jb,hj⟩
  · exact rotationDotsRow20_checked ⟨flatIndex jb,hj⟩
  · exact rotationDotsRow21_checked ⟨flatIndex jb,hj⟩
  · exact rotationDotsRow22_checked ⟨flatIndex jb,hj⟩
  · exact rotationDotsRow23_checked ⟨flatIndex jb,hj⟩
  · exact rotationDotsRow24_checked ⟨flatIndex jb,hj⟩
  · exact rotationDotsRow25_checked ⟨flatIndex jb,hj⟩
  · exact rotationDotsRow26_checked ⟨flatIndex jb,hj⟩
theorem rotation_dot_left (ia jb : Fin 9 × Fin 3) (k : Fin 3) :
    (rotationDots ia jb).left k = rotationIndices ia.1 ia.2 k := by revert ia jb k; decide
theorem rotation_dot_right (ia jb : Fin 9 × Fin 3) (k : Fin 3) :
    (rotationDots ia jb).right k = rotationIndices jb.1 jb.2 k := by revert ia jb k; decide
theorem rotation_product_sound (r : ℝ) (ia jb : Fin 9 × Fin 3) :
    value (parameterInputs r) nodes ((rotationDots ia jb).accumulator 3) =
      (rotationColumns (candidateAt r)*(rotationColumns (candidateAt r)).transpose) ia jb := by
  rw [DotRecipe.extended_sound_fin _ _ _ _ (rotation_dots_checked ia jb)]
  simp only [rotation_dot_left, rotation_dot_right, rotation_entry_sound, Matrix.mul_apply, Matrix.transpose_apply]
theorem augmented_checked (ia jb : Fin 9 × Fin 3) :
    ExtendedSmartAddCheck nodes (constrainedIndices (flatIndex ia) (flatIndex jb))
      ((rotationDots ia jb).accumulator 3)
      (augmentedIndices (flatIndex ia) (flatIndex jb)) := by revert ia jb; decide
theorem shifted_checked (ia jb : Fin 9 × Fin 3) :
    ExtendedSmartAddCheck nodes (augmentedIndices (flatIndex ia) (flatIndex jb))
      (if ia = jb then negativeShift else 11)
      (hessianIndices (flatIndex ia) (flatIndex jb)) := by revert ia jb; decide
theorem negative_shift_sound (values : ℕ → ℝ) : value values nodes negativeShift = -(7/50 : ℝ) := by
  simpa [neg_div] using value_constant values nodes negativeShift (-7) 50 (by decide)
theorem shifted_hessian_entry_sound (r : ℝ) (ia jb : Fin 9 × Fin 3) :
    value (parameterInputs r) nodes (hessianIndices (flatIndex ia) (flatIndex jb)) =
      (constrainedHessian (candidateAt r) +
        rotationColumns (candidateAt r)*(rotationColumns (candidateAt r)).transpose -
          (7/50 : ℝ) • (1 : Matrix (Fin 9 × Fin 3) (Fin 9 × Fin 3) ℝ)) ia jb := by
  rw [extendedSmartAdd_sound _ _ _ _ _ (shifted_checked ia jb),
    extendedSmartAdd_sound _ _ _ _ _ (augmented_checked ia jb),
    constrained_entry_sound, rotation_product_sound]
  by_cases hij : ia = jb
  · subst jb
    rw [if_pos rfl, negative_shift_sound]
    simp [Matrix.sub_apply, Matrix.add_apply, sub_eq_add_neg]
  · rw [if_neg hij, literal_zero]
    simp [Matrix.sub_apply, Matrix.add_apply, Matrix.one_apply, hij]
#print axioms laplacian_entry_sound
#print axioms radial_entry_sound
#print axioms shifted_hessian_entry_sound
end ThomsonN9.Certificates.AmbientKernel
