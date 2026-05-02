import 'dart:math';

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

class HeroBiography {
	final String fullName;
	final String alterEgos;
	final List<String> aliases;
	final String placeOfBirth;
	final String firstAppearance;
	final String publisher;
	final String alignment;

	const HeroBiography({
		required this.fullName,
		required this.alterEgos,
		required this.aliases,
		required this.placeOfBirth,
		required this.firstAppearance,
		required this.publisher,
		required this.alignment,
	});

	factory HeroBiography.fromJson(Map<String, dynamic> json) {
		final aliasData = json['aliases'];
		final aliases = <String>[];
		if (aliasData is List) {
			aliases.addAll(aliasData.whereType<String>().map((item) => item.trim()).where((item) => item.isNotEmpty));
		} else if (aliasData is String && aliasData.isNotEmpty) {
			aliases.add(aliasData.trim());
		}

		return HeroBiography(
			fullName: json['full-name'] as String? ?? '',
			alterEgos: json['alter-egos'] as String? ?? '',
			aliases: aliases,
			placeOfBirth: json['place-of-birth'] as String? ?? '',
			firstAppearance: json['first-appearance'] as String? ?? '',
			publisher: json['publisher'] as String? ?? '',
			alignment: json['alignment'] as String? ?? '',
		);
	}

	Map<String, dynamic> toJson() => {
		'full-name': fullName,
		'alter-egos': alterEgos,
		'aliases': aliases,
		'place-of-birth': placeOfBirth,
		'first-appearance': firstAppearance,
		'publisher': publisher,
		'alignment': alignment,
	};
}

class HeroAppearance {
	final String gender;
	final String race;
	final List<String> height;
	final List<String> weight;
	final String eyeColor;
	final String hairColor;

	const HeroAppearance({
		required this.gender,
		required this.race,
		required this.height,
		required this.weight,
		required this.eyeColor,
		required this.hairColor,
	});

	factory HeroAppearance.fromJson(Map<String, dynamic> json) {
		List<String> parseList(dynamic raw) {
			if (raw is List) {
				return raw.whereType<String>().map((item) => item.trim()).where((item) => item.isNotEmpty).toList();
			}
			if (raw is String && raw.isNotEmpty) {
				return raw.split(',').map((item) => item.trim()).where((item) => item.isNotEmpty).toList();
			}
			return <String>[];
		}

		return HeroAppearance(
			gender: json['gender'] as String? ?? '',
			race: json['race'] as String? ?? '',
			height: parseList(json['height']),
			weight: parseList(json['weight']),
			eyeColor: json['eye-color'] as String? ?? '',
			hairColor: json['hair-color'] as String? ?? '',
		);
	}

	Map<String, dynamic> toJson() => {
		'gender': gender,
		'race': race,
		'height': height,
		'weight': weight,
		'eye-color': eyeColor,
		'hair-color': hairColor,
	};
}

class HeroWork {
	final String occupation;
	final String base;

	const HeroWork({
		required this.occupation,
		required this.base,
	});

	factory HeroWork.fromJson(Map<String, dynamic> json) {
		return HeroWork(
			occupation: json['occupation'] as String? ?? '',
			base: json['base'] as String? ?? '',
		);
	}

	Map<String, dynamic> toJson() => {
		'occupation': occupation,
		'base': base,
	};
}

class HeroConnections {
	final String groupAffiliation;
	final String relatives;

	const HeroConnections({
		required this.groupAffiliation,
		required this.relatives,
	});

	factory HeroConnections.fromJson(Map<String, dynamic> json) {
		return HeroConnections(
			groupAffiliation: json['group-affiliation'] as String? ?? '',
			relatives: json['relatives'] as String? ?? '',
		);
	}

	Map<String, dynamic> toJson() => {
		'group-affiliation': groupAffiliation,
		'relatives': relatives,
	};
}

class HeroSkill {
	final String id;
	final String name;
	final String description;
	final int manaCost;
	final int power;
	final double multiplier;
	final bool usesSpecial;

	const HeroSkill({
		required this.id,
		required this.name,
		required this.description,
		required this.manaCost,
		required this.power,
		required this.multiplier,
		this.usesSpecial = false,
	});
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

	static const List<HeroSkill> defaultSkills = [
		HeroSkill(
			id: 'quick-strike',
			name: 'Quick Strike',
			description: 'A fast precise attack that costs a small amount of mana.',
			manaCost: 14,
			power: 6,
			multiplier: 1.0,
		),
		HeroSkill(
			id: 'focus-blast',
			name: 'Focus Blast',
			description: 'A powerful special attack that deals extra damage.',
			manaCost: 26,
			power: 12,
			multiplier: 1.12,
			usesSpecial: true,
		),
		HeroSkill(
			id: 'overdrive',
			name: 'Overdrive',
			description: 'Push your hero into an overdrive state for a strong strike.',
			manaCost: 22,
			power: 10,
			multiplier: 1.18,
		),
	];

	static const Map<String, List<HeroSkill>> heroSkillSets = {
		'superman': [
			HeroSkill(
				id: 'heat-vision',
				name: 'Heat Vision',
				description: 'Blast the opponent with intense solar energy.',
				manaCost: 24,
				power: 14,
				multiplier: 1.25,
				usesSpecial: true,
			),
			HeroSkill(
				id: 'solar-punch',
				name: 'Solar Punch',
				description: 'A heavy strike charged with solar power.',
				manaCost: 18,
				power: 12,
				multiplier: 1.1,
			),
		],
		'batman': [
			HeroSkill(
				id: 'sharp-strike',
				name: 'Sharp Strike',
				description: 'A precise tactical hit that bypasses armor.',
				manaCost: 14,
				power: 10,
				multiplier: 1.05,
			),
			HeroSkill(
				id: 'gadget-blast',
				name: 'Gadget Blast',
				description: 'Use a gadget to deal extra damage.',
				manaCost: 20,
				power: 12,
				multiplier: 1.15,
			),
		],
		'green-lantern': [
			HeroSkill(
				id: 'ring-construct',
				name: 'Ring Construct',
				description: 'Shape a solid energy attack to strike hard.',
				manaCost: 26,
				power: 14,
				multiplier: 1.2,
				usesSpecial: true,
			),
			HeroSkill(
				id: 'willpower-blast',
				name: 'Willpower Blast',
				description: 'Channel will into a focused strike.',
				manaCost: 16,
				power: 10,
				multiplier: 1.05,
			),
		],
	};

	List<HeroSkill> get skills {
		final key = name
				.toLowerCase()
				.replaceAll(RegExp(r'[^a-z0-9]+'), '-')
				.replaceAll(RegExp(r'^-+|-+$'), '');
		return heroSkillSets[key] ?? defaultSkills;
	}

	static const Map<String, String> heroStorylines = {
		'blaquesmith': 'A master blacksmith from a forgotten realm, wielding enchanted hammers that forge weapons of legend. His journey began when he discovered an ancient forge that granted him superhuman strength and the ability to craft artifacts that bend reality itself.',
		'john-stewart': 'A dedicated Green Lantern Corps member, chosen for his unyielding sense of duty and justice. Trained by the greatest warriors of the universe, he wields a power ring that channels his willpower into constructs of pure energy.',
		'vagabond': 'A wandering hero with no fixed allegiance, driven by a personal code of honor. His past is shrouded in mystery, but his skills in combat and strategy make him a formidable ally or enemy depending on the situation.',
		'bumbleboy': 'A young inventor who created a suit of powered armor after losing his family. Though small in stature, his technological genius and determination make him a giant in battle.',
		'blue-beetle': 'A brilliant scientist who discovered an ancient alien artifact that bonded with him, granting incredible powers. He fights to protect humanity while struggling with the mysterious entity\'s influence.',
		'mr-immortal': 'A man cursed with immortality after a failed experiment, he has witnessed centuries of history. Now he uses his vast experience and regenerative abilities to fight for justice in the modern world.',
		'wiz-kid': 'A teenage prodigy with innate magical abilities, trained by ancient sorcerers. Despite his youth, his wisdom and spellcasting prowess make him a key player in cosmic battles.',
		'superman': 'The last son of Krypton, sent to Earth as a baby and raised by human parents. With powers granted by Earth\'s yellow sun, he fights for truth, justice, and the American way as the world\'s greatest hero.',
		'batman': 'A billionaire playboy who witnessed his parents\' murder as a child, vowing to fight crime. Using his intellect, wealth, and martial arts training, he operates as a vigilante in Gotham City.',
		'wonder-woman': 'An Amazonian princess from Paradise Island, blessed with superhuman strength and combat skills. She fights for peace and justice, wielding her lasso of truth and indestructible bracelets.',
		'spider-man': 'A teenage genius bitten by a radioactive spider, gaining incredible powers. Balancing school, work, and heroism, he protects New York City while dealing with the responsibilities of great power.',
		'iron-man': 'A brilliant inventor and billionaire who created a powered suit of armor after being captured. Using his technology and wit, he fights threats as one of Earth\'s mightiest heroes.',
		'captain-america': 'A super-soldier enhanced during World War II, frozen in ice and revived in the modern era. He embodies patriotism and fights for freedom with his indestructible shield.',
		'hulk': 'A brilliant scientist exposed to gamma radiation, transforming into a rage-fueled monster. Struggling to control his anger, he becomes an unstoppable force when provoked.',
		'thor': 'The god of thunder from Asgard, wielding the mighty hammer Mjolnir. He protects both the Nine Realms and Earth from cosmic threats with his divine powers.',
		'flash': 'The fastest man alive, gaining super-speed after a freak accident. He uses his velocity to fight crime and protect Central City from various threats.',
		'green-arrow': 'A billionaire archer who fights crime with his exceptional marksmanship and trick arrows. He champions social justice and fights corruption in Star City.',
		'aquaman': 'The king of Atlantis, possessing superhuman strength and the ability to communicate with sea life. He protects both the oceans and the surface world from threats.',
		'deadpool': 'A mercenary with a healing factor and fourth-wall awareness, known for his humor and unpredictability. He fights for his own reasons in a chaotic world.',
		'wolverine': 'A mutant with adamantium claws and a healing factor, surviving through centuries of conflict. His feral instincts and combat skills make him a legendary warrior.',
		'storm': 'A mutant weather goddess from Africa, controlling the elements. As an X-Men leader, she fights for mutant rights and global peace.',
		'jean-grey': 'A powerful telepath and telekinetic mutant, struggling with her immense psychic abilities. She has faced both heroic and dark transformations.',
		'cyclops': 'The field leader of the X-Men, firing powerful optic blasts. He fights for mutant-human coexistence while dealing with personal loss.',
		'rogue': 'A mutant who absorbs others\' powers and memories through touch. She wears gloves to protect others and fights as an X-Man.',
		'beast': 'A brilliant scientist and mutant with enhanced strength and agility. His intellect and acrobatics make him a valuable asset to the X-Men.',
		'colossus': 'A Russian mutant who transforms into organic steel, possessing immense strength. He fights for peace and protects his friends.',
		'nightcrawler': 'A teleporting mutant with demonic appearance, using his agility and faith to fight prejudice. He serves as a bridge between worlds.',
		'jubilee': 'A young mutant who creates explosive energy plasmoids. She brings youthful energy and optimism to the X-Men.',
		'angel': 'A mutant with feathered wings, using his aerial abilities and wealth to fight crime. He has faced both heroic and villainous paths.',
		'iceman': 'A mutant who manipulates ice and cold, creating weapons and shields. He uses his powers to protect and sometimes to rebel.',
		'firestar': 'A mutant who generates microwave energy blasts. She fights alongside the X-Men with her powerful energy manipulation.',
		'magneto': 'A Holocaust survivor who believes mutants should rule humanity. His magnetic powers and ideology make him a complex antagonist.',
		'doctor-doom': 'The brilliant ruler of Latveria, wielding advanced technology and sorcery. He seeks to conquer the world with his intellect and power.',
		'loki': 'The god of mischief from Asgard, using trickery and magic. His schemes often threaten both gods and mortals.',
		'venom': 'A symbiotic alien entity bonded to a human host, creating a monstrous anti-hero. It struggles between good and evil impulses.',
		'joker': 'A chaotic criminal mastermind obsessed with Batman. His insanity and schemes bring terror to Gotham City.',
		'lex-luthor': 'A brilliant businessman and Superman\'s arch-nemesis. He uses his intellect and resources to challenge the Man of Steel.',
		'darkseid': 'The tyrannical ruler of Apokolips, seeking ultimate power. His quest for the Anti-Life Equation threatens all existence.',
		'thanos': 'A cosmic warlord seeking balance through genocide. His immense power and philosophy make him one of the universe\'s greatest threats.',
		'galactus': 'A cosmic entity who consumes planets for sustenance. He serves as a force of nature, heralded by powerful beings.',
		'silver-surfer': 'A former herald of Galactus, now protecting Earth. His power cosmic and sense of morality guide his heroic path.',
		'doomslayer': 'A legendary demon hunter from Hell, wielding powerful weapons. He fights against demonic forces across realities.',
		'hellboy': 'A demon raised by humans, fighting supernatural threats. His stone hand and occult knowledge make him a paranormal investigator.',
		'constantine': 'A chain-smoking exorcist and occult detective. He navigates the supernatural underworld to protect humanity.',
		'zatanna': 'A powerful sorceress who speaks spells backward. Her magic and showmanship make her a formidable mystical hero.',
		'doctor-strange': 'The Sorcerer Supreme, mastering mystical arts. He protects Earth from magical and cosmic threats.',
		'scarlet-witch': 'A mutant with reality-warping powers, shaped by trauma. Her abilities make her both powerful and unpredictable.',
		'vision': 'An android created by Ultron, possessing density manipulation. He fights for humanity despite his artificial nature.',
		'falcon': 'A skilled pilot and martial artist, using wings to fly. He fights alongside Captain America for justice.',
		'winter-soldier': 'A brainwashed assassin with enhanced abilities. He struggles with his past while fighting for redemption.',
		'black-widow': 'A master spy and assassin, trained by the KGB. Her skills and espionage make her a deadly operative.',
		'hawkeye': 'An exceptional archer and marksman. His precision and trick arrows make him a valuable ally.',
		'ant-man': 'A scientist who can shrink and communicate with ants. His size-changing abilities provide unique tactical advantages.',
		'wasp': 'A scientist who can shrink and fly, creating energy blasts. She fights alongside Ant-Man as a founding Avenger.',
		'gamora': 'An assassin raised by Thanos, now fighting against him. Her combat skills and redemption arc make her a fierce warrior.',
		'rocket': 'A genetically enhanced raccoon with cybernetics. His weapons expertise and cunning make him a galactic adventurer.',
		'groot': 'A tree-like being who can regenerate and grow. His simple nature belies his strength and loyalty.',
		'drax': 'A warrior seeking revenge against Thanos. His strength and literal thinking make him a formidable fighter.',
		'star-lord': 'A charismatic thief and leader of the Guardians. His mix of bravado and heroism protects the galaxy.',
		'mantis': 'An empath with antennae that read emotions. Her abilities aid the Guardians in their cosmic adventures.',
		'nebula': 'A cybernetically enhanced warrior, formerly Thanos\' daughter. Her combat prowess and complex loyalties define her.',
		'black-panther': 'The king of Wakanda, enhanced by vibranium. He protects his nation and fights for global justice.',
		'killmonger': 'A Wakandan revolutionary seeking to arm oppressed peoples. His ideology clashes with traditional Wakandan values.',
		'she-hulk': 'Bruce Banner\'s cousin, gaining Hulk-like strength. She uses her powers as a lawyer and superhero.',
		'squirrel-girl': 'A mutant with squirrel-like abilities, defeating powerful foes. Her unassuming nature hides great potential.',
		'moon-girl': 'A genius child with enhanced intelligence. She uses her brilliance to solve problems and fight crime.',
		'miles-morales': 'A teenage Spider-Man from another dimension. He balances school, family, and heroism in Brooklyn.',
		'static': 'A teenager who gains electromagnetic powers. He fights crime in Dakota City with his gadgets and abilities.',
		'booster-gold': 'A time-traveling hero from the future, using advanced technology. His showboating personality hides genuine heroism.',
		'cyborg': 'Humans enhanced with cybernetic technology. They combine human will with machine power.',
		'martian-manhunter': 'Shape-shifting aliens with vast powers. They protect Earth while hiding their true nature.',
		'hawkgirl': 'Warrior reincarnated through time, wielding maces. She fights eternal battles against evil.',
		'swamp-thing': 'Plant-based entities connected to the Green. They protect nature and fight corruption.',
		'hellblazer': 'Cynical magicians battling supernatural forces. They operate in moral gray areas.',
		'deadman': 'Ghostly heroes possessing others\' bodies. They fight injustice from beyond the grave.',
		'sandman': 'Dream lords controlling the realm of sleep. They influence reality through dreams.',
		'vertigo': 'Reality-warping mutants with probability manipulation. They alter chances and outcomes.',
		'bumblebee': 'Shrinking heroes with flight and energy blasts. They punch above their weight class.',
		'geoffrey-stalker': 'Mysterious figures with unknown powers. Their true nature remains enigmatic.',
	};


	final String id;
	final String name;
	final String imageUrl;
	final String publisher;
	final String alignment;
	final String fullName;
	final String alterEgos;
	final PowerStats powerStats;
	final HeroBiography biography;
	final HeroAppearance appearance;
	final HeroWork work;
	final HeroConnections connections;

	const HeroModel({
		required this.id,
		required this.name,
		required this.imageUrl,
		required this.publisher,
		required this.alignment,
		required this.fullName,
		required this.alterEgos,
		required this.powerStats,
		required this.biography,
		required this.appearance,
		required this.work,
		required this.connections,
	});

	int get maxHp => max(500, ((powerStats.durability + powerStats.power) * 3 ~/ 2) + 200);
	int get maxMana => max(150, ((powerStats.intelligence + powerStats.power) * 3 ~/ 2) + 80);
	int get attack => ((powerStats.strength + powerStats.combat) / 2).round();
	int get specialAttack =>
			((powerStats.intelligence + powerStats.power) / 2).round();
	int get defense => ((powerStats.durability + powerStats.combat) / 4).round();
	int get initiative => powerStats.speed;

	String get storyline {
		final key = name
				.toLowerCase()
				.replaceAll(RegExp(r'[^a-z0-9]+'), '-')
				.replaceAll(RegExp(r'^-+|-+$'), '');
		return heroStorylines[key] ?? 'A mysterious hero whose origins remain shrouded in legend. Their powers and abilities make them a formidable force in battle.';
	}

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
			biography: HeroBiography.fromJson(biography ?? <String, dynamic>{}),
			appearance: HeroAppearance.fromJson((json['appearance'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{}),
			work: HeroWork.fromJson((json['work'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{}),
			connections: HeroConnections.fromJson((json['connections'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{}),
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
		'biography': biography.toJson(),
		'appearance': appearance.toJson(),
		'work': work.toJson(),
		'connections': connections.toJson(),
	};
}
