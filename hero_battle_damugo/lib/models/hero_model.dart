class PowerStats {
	final int intelligence;
	final int strength;
	final int speed;
	final int durability;
	final int power;
	final int combat;

	const PowerStats({
		required this.intelligence,
		required this.strength,
		required this.speed,
		required this.durability,
		required this.power,
		required this.combat,
	});

	factory PowerStats.fromJson(Map<String, dynamic> json) {
		int parse(dynamic value) {
			final raw = value?.toString();
			if (raw == null || raw == 'null') {
				return 50;
			}
			return int.tryParse(raw) ?? 50;
		}

		return PowerStats(
			intelligence: parse(json['intelligence']),
			strength: parse(json['strength']),
			speed: parse(json['speed']),
			durability: parse(json['durability']),
			power: parse(json['power']),
			combat: parse(json['combat']),
		);
	}

	Map<String, dynamic> toJson() => {
				'intelligence': intelligence,
				'strength': strength,
				'speed': speed,
				'durability': durability,
				'power': power,
				'combat': combat,
			};
}

class HeroModel {
	static const Map<String, List<String>> manualImageOverrides = {
		'blaquesmith': ['asset:assets/images/blaquesmith.png'],
		'john-stewart': ['asset:assets/images/johnstewart.png'],
		'green-lantern': ['asset:assets/images/overrides/john-stewart.svg'],
		'vagabond': ['asset:assets/images/vagabond.png'],
		'bumbleboy': ['asset:assets/images/bumbleboy.png'],
		'blue-beetle': ['asset:assets/images/BlueBeetle.png'],
		'mr-immortal': ['asset:assets/images/MrImmortal.png'],
		'wiz-kid': ['asset:assets/images/wizkid.png'],
		'vertigo-ii': ['asset:assets/images/overrides/blaquesmith.svg'],
	};

	final String id;
	final String name;
	final String imageUrl;
	final String publisher;
	final String alignment;
	final String fullName;
	final String alterEgos;
	final PowerStats powerStats;

	const HeroModel({
		required this.id,
		required this.name,
		required this.imageUrl,
		required this.publisher,
		required this.alignment,
		required this.fullName,
		required this.alterEgos,
		required this.powerStats,
	});

	int get maxHp => ((powerStats.durability + powerStats.power) / 2).round();
	int get attack => ((powerStats.strength + powerStats.combat) / 2).round();
	int get specialAttack =>
			((powerStats.intelligence + powerStats.power) / 2).round();
	int get defense => ((powerStats.durability + powerStats.combat) / 4).round();
	int get initiative => powerStats.speed;

	List<String> get imageSearchTerms {
		final terms = <String>{
			name,
			if (fullName.isNotEmpty) fullName,
			if (alterEgos.isNotEmpty && alterEgos != 'No alter egos found.') ...alterEgos.split(RegExp(r'[,;/]')),
		};

		final strippedRoman = name.replaceAll(RegExp(r'\s+(?:I|II|III|IV|V|VI|VII|VIII|IX|X)$'), '');
		if (strippedRoman != name && strippedRoman.isNotEmpty) {
			terms.add(strippedRoman);
		}

		return terms.where((term) => term.trim().isNotEmpty).toList();
	}

	List<String> get displayImageCandidates {
		if (imageUrl.isEmpty) {
			return <String>[];
		}

		final idNumber = int.tryParse(id);
		if (idNumber == null) {
			return <String>[imageUrl];
		}

		final normalized = name
				.toLowerCase()
				.replaceAll(RegExp(r'[^a-z0-9]+'), '-')
				.replaceAll(RegExp(r'^-+|-+$'), '');

		final parts = normalized.isEmpty
				? <String>[]
				: normalized.split('-').where((p) => p.isNotEmpty).toList();

		final withoutSingleLetters = parts.where((p) => p.length > 1).toList();
		final withoutStopwords = parts.where((p) => p != 'the').toList();
		final compact = parts.where((p) => p != 'the' && p.length > 1).toList();

		String? joinSlug(List<String> p) {
			if (p.isEmpty) {
				return null;
			}
			return p.join('-');
		}

		final slugCandidates = <String>{
			if (normalized.isNotEmpty) normalized,
			if (joinSlug(withoutSingleLetters) != null) joinSlug(withoutSingleLetters)!,
			if (joinSlug(withoutStopwords) != null) joinSlug(withoutStopwords)!,
			if (joinSlug(compact) != null) joinSlug(compact)!,
		};

		final overrideCandidates = <String>{
			..._lookupManualOverrides(name),
			..._lookupManualOverrides(fullName),
			..._lookupManualOverrides(alterEgos),
			...imageSearchTerms.expand(_lookupManualOverrides),
		};

		final urls = <String>[
			...overrideCandidates,
			imageUrl,
			...slugCandidates.map(
				(slug) => 'https://akabab.github.io/superhero-api/api/images/lg/$idNumber-$slug.jpg',
			),
		];

		return urls;
	}

	static List<String> _lookupManualOverrides(String value) {
		final key = value
				.toLowerCase()
				.replaceAll(RegExp(r'[^a-z0-9]+'), '-')
				.replaceAll(RegExp(r'^-+|-+$'), '');
		return manualImageOverrides[key] ?? <String>[];
	}

	factory HeroModel.fromJson(Map<String, dynamic> json) {
		final biography = (json['biography'] as Map?)?.cast<String, dynamic>();
		final imageMap = (json['image'] as Map?)?.cast<String, dynamic>();
		final powerStatsMap = (json['powerstats'] as Map?)?.cast<String, dynamic>();
		final savedPowerStatsMap = (json['powerStats'] as Map?)?.cast<String, dynamic>();

		return HeroModel(
			id: json['id'].toString(),
			name: json['name'] as String? ?? 'Unknown',
			imageUrl:
					(json['imageUrl'] as String?) ??
					(imageMap?['url'] as String?) ??
					'',
			publisher:
					(json['publisher'] as String?) ??
					(biography?['publisher'] as String?) ??
					'',
			alignment:
					(json['alignment'] as String?) ??
					(biography?['alignment'] as String?) ??
					'neutral',
			fullName:
					(json['fullName'] as String?) ??
					(biography?['full-name'] as String?) ??
					'',
			alterEgos:
					(json['alterEgos'] as String?) ??
					(biography?['alter-egos'] as String?) ??
					'',
			powerStats: PowerStats.fromJson(
				powerStatsMap ?? savedPowerStatsMap ?? <String, dynamic>{},
			),
		);
	}

	Map<String, dynamic> toJson() => {
				'id': id,
				'name': name,
				'imageUrl': imageUrl,
				'publisher': publisher,
				'alignment': alignment,
				'fullName': fullName,
				'alterEgos': alterEgos,
				'powerStats': powerStats.toJson(),
			};
}

