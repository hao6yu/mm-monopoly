class_name CityThemes
extends RefCounted

const BOARD_IDS := [
	"usa",
	"usa_new_york",
	"usa_los_angeles",
	"uk",
	"uk_edinburgh",
	"uk_manchester",
	"france",
	"france_lyon",
	"france_marseille",
	"japan",
	"japan_osaka",
	"japan_kyoto",
	"china",
	"china_shanghai",
	"china_hong_kong",
	"mexico",
	"mexico_guadalajara",
	"mexico_cancun",
]


static func all_board_ids() -> Array[String]:
	var result: Array[String] = []
	for board_id in BOARD_IDS:
		result.append(board_id)
	return result


static func has_theme(board_id: String) -> bool:
	return board_id in BOARD_IDS


static func get_theme(board_id: String) -> Dictionary:
	var themes := _themes()
	return (themes.get(board_id, themes["usa_new_york"]) as Dictionary).duplicate(true)


static func _theme(
	city: String,
	subtitle: String,
	shape: String,
	sky_top: String,
	sky_horizon: String,
	water: String,
	land: String,
	route: String,
	accent: String,
	architecture: String,
	scenic: Array,
	landmarks: Array,
	transport: String = "none"
) -> Dictionary:
	return {
		"city": city,
		"subtitle": subtitle,
		"shape": shape,
		"sky_top": sky_top,
		"sky_horizon": sky_horizon,
		"water": water,
		"land": land,
		"route": route,
		"accent": accent,
		"architecture": architecture,
		"scenic": scenic,
		"landmarks": landmarks,
		"transport": transport,
	}


static func _landmark(
	kind: String,
	label: String,
	x: float,
	z: float,
	scale: float = 1.0
) -> Dictionary:
	return {
		"kind": kind,
		"label": label,
		"x": x,
		"z": z,
		"scale": scale,
	}


static func _themes() -> Dictionary:
	return {
		"usa": _theme(
			"ATLANTIC CITY",
			"BOARDWALK & STEEL PIER THEME PARK",
			"barrier_island",
			"#278dcc",
			"#c9f3ff",
			"#168fb1",
			"#79a96b",
			"#bf5a45",
			"#ffd166",
			"#f1d0a5",
			[
				"Marina", "Garden Pier", "Surf Club", "Absecon Inlet",
				"Lucy Pier", "Chelsea Harbor", "Diving Horse", "Jazz Walk",
				"Ocean Pavilion", "Resort Row", "Beach Tram", "Sunset Deck",
			],
			[
				_landmark("wheel", "STEEL PIER", -2.9, -7.2, 1.0),
				_landmark("lighthouse", "ABSECON LIGHT", 2.7, 8.3, 1.0),
				_landmark("palace", "BOARDWALK HALL", 1.9, -1.6, 0.9),
				_landmark("modern_tower", "RESORTS", -2.1, 3.8, 0.9),
				_landmark("sign", "BOARDWALK", 0.0, 10.0, 1.1),
			],
			"coast"
		),
		"usa_new_york": _theme(
			"MANHATTAN",
			"52-LOCATION HARBOR THEME PARK",
			"manhattan",
			"#2f86c9",
			"#bfeaff",
			"#1596b6",
			"#7f9674",
			"#9e4440",
			"#ffe29a",
			"#d7d0bc",
			[
				"Battery Park", "High Line", "Bryant Park", "Radio City",
				"Museum Mile", "Apollo", "Riverside", "Governors Isle",
				"Seaport", "City Hall", "Little Italy", "Financial District",
			],
			[
				_landmark("modern_tower", "ONE WORLD", -0.7, -10.8, 1.2),
				_landmark("park", "CENTRAL PARK", 0.0, 6.5, 1.2),
				_landmark("monument", "LIBERTY", 0.0, -17.4, 1.1),
				_landmark("bridge", "BROOKLYN BRIDGE", 7.6, -6.3, 1.1),
				_landmark("sign", "TIMES SQUARE", -2.1, 1.0, 1.0),
			],
			"coast"
		),
		"usa_los_angeles": _theme(
			"LOS ANGELES",
			"PACIFIC MOVIE-CITY THEME PARK",
			"pacific_coast",
			"#3e94d1",
			"#ffd7ad",
			"#178fb7",
			"#8fae68",
			"#d16b48",
			"#ffcf62",
			"#e8d3b4",
			[
				"Venice Canals", "Sunset Plaza", "Mulholland", "Arts Row",
				"Malibu Pier", "Echo Lake", "Studio Gate", "Palm Walk",
				"Ocean Avenue", "Little Tokyo", "Broadway Theatre", "Getty Tram",
			],
			[
				_landmark("sign", "HOLLYWOOD", -2.8, 8.2, 1.1),
				_landmark("dome", "GRIFFITH", 2.8, 5.8, 0.95),
				_landmark("wheel", "SANTA MONICA", -3.3, -7.7, 1.0),
				_landmark("modern_tower", "DOWNTOWN LA", 2.0, -2.0, 1.0),
				_landmark("lighthouse", "MALIBU", -2.6, 1.4, 0.8),
			],
			"coast"
		),
		"uk": _theme(
			"LONDON",
			"ROYAL THAMES THEME PARK",
			"river_city",
			"#5d86aa",
			"#d9ecf1",
			"#427e9b",
			"#7f9d72",
			"#9f4744",
			"#f0c95c",
			"#cbbba5",
			[
				"Covent Garden", "Hyde Park", "Soho", "South Bank",
				"Greenwich", "Camden Lock", "Kew Gardens", "Borough Market",
				"Royal Albert Hall", "Piccadilly Circus", "St James's", "Canary Wharf",
			],
			[
				_landmark("clock_tower", "BIG BEN", -2.1, -2.2, 1.0),
				_landmark("wheel", "LONDON EYE", 2.0, -3.3, 1.0),
				_landmark("bridge", "TOWER BRIDGE", 2.6, 6.0, 1.0),
				_landmark("palace", "BUCKINGHAM", -2.4, 4.4, 0.95),
				_landmark("cathedral", "ST PAUL'S", 1.3, 1.3, 0.9),
			]
		),
		"uk_edinburgh": _theme(
			"EDINBURGH",
			"CASTLE HILL THEME PARK",
			"highland",
			"#5b83a6",
			"#d6e8e7",
			"#3c7890",
			"#738d61",
			"#8d4d43",
			"#e3bf63",
			"#a99b88",
			[
				"Grassmarket", "Dean Village", "Calton Hill", "Leith Walk",
				"Portobello", "New Town", "Princes Garden", "Meadows",
				"Royal Botanic", "Cramond", "Waverley Steps", "Festival Square",
			],
			[
				_landmark("castle", "EDINBURGH CASTLE", -2.5, -2.2, 1.05),
				_landmark("monument", "SCOTT MONUMENT", 1.7, -0.3, 1.0),
				_landmark("cathedral", "ST GILES", 0.0, 3.3, 0.85),
				_landmark("mountain", "ARTHUR'S SEAT", 2.8, 7.8, 1.1),
				_landmark("palace", "HOLYROOD", -2.0, 8.1, 0.9),
			]
		),
		"uk_manchester": _theme(
			"MANCHESTER",
			"CANALS & FOOTBALL THEME PARK",
			"canal_city",
			"#557fa0",
			"#d6ebee",
			"#3c829b",
			"#71906c",
			"#9c4d40",
			"#f2c659",
			"#b79a7a",
			[
				"Northern Quarter", "Castlefield", "Ancoats", "MediaCity",
				"Canal Street", "Piccadilly", "Spinningfields", "Deansgate",
				"Salford Quays", "Oxford Road", "Albert Square", "Victoria Baths",
			],
			[
				_landmark("clock_tower", "TOWN HALL", -1.8, -1.6, 0.9),
				_landmark("stadium", "OLD TRAFFORD", -2.8, 6.8, 1.0),
				_landmark("stadium", "ETIHAD", 2.8, 7.6, 0.95),
				_landmark("modern_tower", "BEETHAM", 2.2, -4.8, 1.0),
				_landmark("palace", "JOHN RYLANDS", 0.0, 3.0, 0.85),
			]
		),
		"france": _theme(
			"PARIS",
			"SEINE LIGHTS THEME PARK",
			"river_city",
			"#5a8fc5",
			"#f1e6d2",
			"#3b86a1",
			"#799568",
			"#a24e50",
			"#f1c75b",
			"#ddd0bb",
			[
				"Montmartre", "Latin Quarter", "Tuileries", "Le Marais",
				"Saint-Germain", "Canal Saint-Martin", "Île Saint-Louis", "Versailles Gate",
				"Opera", "Invalides", "Luxembourg Garden", "La Défense",
			],
			[
				_landmark("eiffel", "EIFFEL TOWER", -2.4, -3.7, 1.1),
				_landmark("monument", "ARC DE TRIOMPHE", -2.1, 4.8, 0.9),
				_landmark("pyramid", "LOUVRE", 1.7, -1.4, 0.9),
				_landmark("cathedral", "NOTRE-DAME", 1.9, 4.3, 0.85),
				_landmark("dome", "SACRÉ-CŒUR", 0.0, 8.6, 0.9),
			]
		),
		"france_lyon": _theme(
			"LYON",
			"RHÔNE–SAÔNE THEME PARK",
			"confluence",
			"#5592c2",
			"#e6ecdc",
			"#3d8fa4",
			"#7b996b",
			"#a34f45",
			"#f1c557",
			"#d5b897",
			[
				"Vieux Lyon", "Croix-Rousse", "Presqu'île", "Bellecour",
				"Traboules", "Halles", "Confluence", "Tête d'Or",
				"Terreaux", "Brotteaux", "Guillotière", "Lumière Quarter",
			],
			[
				_landmark("cathedral", "FOURVIÈRE", -2.5, 6.7, 1.0),
				_landmark("palace", "HÔTEL-DIEU", 1.7, -1.4, 0.9),
				_landmark("modern_tower", "PART-DIEU", 2.6, 4.2, 0.95),
				_landmark("monument", "BELLECOUR", -0.6, 1.4, 0.85),
				_landmark("modern_tower", "CONFLUENCE", 0.0, -7.8, 0.9),
			]
		),
		"france_marseille": _theme(
			"MARSEILLE",
			"MEDITERRANEAN PORT THEME PARK",
			"mediterranean_coast",
			"#3d94cf",
			"#ffe0b5",
			"#168dad",
			"#8ba46d",
			"#b95843",
			"#ffd064",
			"#e4c5a2",
			[
				"Le Panier", "La Canebière", "Corniche", "Calanques",
				"Frioul", "Prado", "Joliette", "Cours Julien",
				"Fort Saint-Jean", "Les Goudes", "Longchamp", "Castellane",
			],
			[
				_landmark("cathedral", "NOTRE-DAME", 1.8, 7.6, 1.0),
				_landmark("lighthouse", "VIEUX-PORT", -2.6, -4.7, 0.9),
				_landmark("modern_tower", "MUCEM", 2.0, -2.1, 0.9),
				_landmark("castle", "CHÂTEAU D'IF", -3.2, 4.4, 0.85),
				_landmark("stadium", "VÉLODROME", 2.4, 2.7, 0.95),
			],
			"coast"
		),
		"japan": _theme(
			"TOKYO",
			"NEON BAY THEME PARK",
			"bay_city",
			"#4a80b9",
			"#f2cfe0",
			"#287f9d",
			"#78966d",
			"#b94e5d",
			"#ffd05f",
			"#b9c3cf",
			[
				"Asakusa", "Akihabara", "Harajuku", "Ginza",
				"Shinjuku", "Odaiba", "Tsukiji", "Roppongi",
				"Marunouchi", "Ueno", "Omotesando", "Nihombashi",
			],
			[
				_landmark("tower", "TOKYO TOWER", -2.3, -2.7, 1.0),
				_landmark("modern_tower", "SKYTREE", 2.6, 7.7, 1.15),
				_landmark("temple", "SENSŌ-JI", -2.4, 6.5, 0.9),
				_landmark("sign", "SHIBUYA", 2.0, 1.2, 1.0),
				_landmark("palace", "IMPERIAL PALACE", 0.0, -6.9, 0.9),
			]
		),
		"japan_osaka": _theme(
			"OSAKA",
			"CASTLE & CANAL THEME PARK",
			"bay_city",
			"#4b85ba",
			"#f7d5cf",
			"#2a829d",
			"#78976a",
			"#b04f54",
			"#ffcb55",
			"#c7b8a2",
			[
				"Dotonbori", "Namba", "Umeda", "Shinsekai",
				"Tempozan", "Nakanoshima", "Kuromon", "Amerikamura",
				"Tennoji", "Kitashinchi", "Sakai", "Expo Park",
			],
			[
				_landmark("castle", "OSAKA CASTLE", -2.2, 5.2, 1.0),
				_landmark("tower", "TSŪTENKAKU", -2.6, -3.6, 0.95),
				_landmark("sign", "DOTONBORI", 1.6, -1.2, 1.0),
				_landmark("modern_tower", "UMEDA SKY", 2.3, 5.9, 1.0),
				_landmark("wheel", "TEMPOZAN", 2.9, -6.8, 0.95),
			],
			"coast"
		),
		"japan_kyoto": _theme(
			"KYOTO",
			"TEMPLES & GARDENS THEME PARK",
			"garden_city",
			"#608caf",
			"#f0d8cc",
			"#4d8c9e",
			"#719160",
			"#a94d49",
			"#efc453",
			"#c6a77f",
			[
				"Gion", "Pontocho", "Arashiyama", "Philosopher Path",
				"Uji", "Higashiyama", "Bamboo Grove", "Sannenzaka",
				"Imperial Garden", "Nijō", "Ryoan-ji", "Shimogamo",
			],
			[
				_landmark("temple", "FUSHIMI INARI", -2.6, -5.9, 1.0),
				_landmark("temple", "KIYOMIZU-DERA", 2.2, 2.7, 0.95),
				_landmark("temple", "KINKAKU-JI", -2.2, 6.7, 0.9),
				_landmark("tower", "KYOTO TOWER", 2.4, -4.3, 0.9),
				_landmark("park", "ARASHIYAMA", 1.2, 7.8, 1.0),
			]
		),
		"china": _theme(
			"BEIJING",
			"IMPERIAL CAPITAL THEME PARK",
			"imperial_city",
			"#5f8db1",
			"#eed6b2",
			"#4d8494",
			"#829263",
			"#a8423f",
			"#efc34d",
			"#c9aa82",
			[
				"Nanluoguxiang", "Houhai", "Wangfujing", "Sanlitun",
				"Drum Tower", "Olympic Park", "Beihai", "Summer Palace",
				"Chaoyang", "Dongcheng", "Silk Street", "Lama Temple",
			],
			[
				_landmark("palace", "FORBIDDEN CITY", 0.0, 1.0, 1.1),
				_landmark("temple", "TEMPLE OF HEAVEN", -2.7, -5.6, 1.0),
				_landmark("monument", "TIANANMEN", 0.0, -3.4, 0.9),
				_landmark("modern_tower", "CCTV", 2.6, 3.7, 1.0),
				_landmark("wall", "GREAT WALL", 0.0, 8.5, 1.0),
			]
		),
		"china_shanghai": _theme(
			"SHANGHAI",
			"HUANGPU SKYLINE THEME PARK",
			"river_city",
			"#4b87bc",
			"#d8e6e9",
			"#34859d",
			"#77946b",
			"#a84b48",
			"#f2c650",
			"#bec8cf",
			[
				"The Bund", "Tianzifang", "Xintiandi", "People's Square",
				"French Concession", "Nanjing Road", "Pudong", "Jing'an",
				"Yu Garden", "Longhua", "Zhujiajiao", "Hongqiao",
			],
			[
				_landmark("tower", "ORIENTAL PEARL", 2.4, -2.7, 1.05),
				_landmark("modern_tower", "SHANGHAI TOWER", 2.3, 2.8, 1.15),
				_landmark("palace", "THE BUND", -2.4, -1.0, 0.9),
				_landmark("modern_tower", "JIN MAO", 1.0, 6.4, 0.95),
				_landmark("temple", "YU GARDEN", -2.2, 5.2, 0.9),
			],
			"coast"
		),
		"china_hong_kong": _theme(
			"HONG KONG",
			"VICTORIA HARBOUR THEME PARK",
			"harbor_islands",
			"#3d86bb",
			"#d8eff0",
			"#1f809d",
			"#6e9465",
			"#a94a45",
			"#f3c74e",
			"#b9c6ce",
			[
				"Central", "Tsim Sha Tsui", "Mong Kok", "Causeway Bay",
				"Repulse Bay", "Stanley", "Wan Chai", "Aberdeen",
				"Temple Street", "Lan Kwai Fong", "Ocean Park", "Happy Valley",
			],
			[
				_landmark("modern_tower", "BANK OF CHINA", -2.1, -2.8, 1.05),
				_landmark("modern_tower", "IFC", 2.2, -1.0, 1.1),
				_landmark("mountain", "VICTORIA PEAK", -1.9, 7.0, 1.1),
				_landmark("lighthouse", "STAR FERRY", 2.6, 4.3, 0.85),
				_landmark("monument", "TIAN TAN BUDDHA", 1.2, -7.5, 0.95),
			],
			"coast"
		),
		"mexico": _theme(
			"MEXICO CITY",
			"VALLEY OF MONUMENTS THEME PARK",
			"basin_city",
			"#4b92bf",
			"#f4d9b4",
			"#48869a",
			"#75935f",
			"#b14d43",
			"#f0c34f",
			"#d1af83",
			[
				"Coyoacán", "Xochimilco", "Roma Norte", "Condesa",
				"Polanco", "Chapultepec", "Zócalo", "Reforma",
				"San Ángel", "Teotihuacán", "Santa Fe", "Zona Rosa",
			],
			[
				_landmark("monument", "ÁNGEL", -2.2, -2.5, 1.0),
				_landmark("dome", "BELLAS ARTES", 1.7, -0.8, 0.95),
				_landmark("cathedral", "ZÓCALO", 0.0, 4.2, 0.9),
				_landmark("modern_tower", "TORRE LATINO", 2.4, 3.0, 1.0),
				_landmark("castle", "CHAPULTEPEC", -2.1, 7.4, 0.9),
			]
		),
		"mexico_guadalajara": _theme(
			"GUADALAJARA",
			"PLAZAS & MARIACHI THEME PARK",
			"basin_city",
			"#4e91bb",
			"#f4d7ae",
			"#4e8796",
			"#7a925f",
			"#b44f42",
			"#efc34d",
			"#d1ae82",
			[
				"Tlaquepaque", "Zapopan", "Analco", "Americana",
				"Chapultepec", "Tequila", "Lake Chapala", "San Juan de Dios",
				"Providencia", "Tonalá", "Plaza del Sol", "Centro Histórico",
			],
			[
				_landmark("cathedral", "CATEDRAL", 0.0, 1.7, 1.0),
				_landmark("monument", "LA MINERVA", -2.5, -2.8, 0.95),
				_landmark("palace", "HOSPICIO CABAÑAS", 2.1, 4.7, 0.9),
				_landmark("palace", "TEATRO DEGOLLADO", 2.4, -1.0, 0.85),
				_landmark("stadium", "JALISCO", -2.3, 7.2, 0.9),
			]
		),
		"mexico_cancun": _theme(
			"CANCÚN",
			"CARIBBEAN MAYA THEME PARK",
			"caribbean_coast",
			"#2c9bd0",
			"#ddfbff",
			"#10a4bd",
			"#80aa68",
			"#c56545",
			"#ffd45f",
			"#e4c89c",
			[
				"Playa Delfines", "Isla Mujeres", "Punta Cancún", "Nichupté",
				"Puerto Morelos", "Cozumel", "Tulum", "Xcaret",
				"Cenote Walk", "Hotel Lagoon", "Maya Market", "Coral Pier",
			],
			[
				_landmark("pyramid", "CHICHÉN ITZÁ", 0.0, 6.4, 1.05),
				_landmark("temple", "TULUM", -2.5, 1.8, 0.9),
				_landmark("modern_tower", "HOTEL ZONE", 2.4, -1.5, 1.0),
				_landmark("lighthouse", "PUNTA CANCÚN", -2.8, -6.2, 0.95),
				_landmark("wheel", "LA ISLA", 2.7, 5.5, 0.9),
			],
			"coast"
		),
	}
