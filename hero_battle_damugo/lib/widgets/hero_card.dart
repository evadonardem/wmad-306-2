import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/hero_model.dart';
import 'hero_image.dart';

class HeroCard extends StatelessWidget {
	const HeroCard({
		super.key,
		required this.hero,
		required this.onTap,
		this.trailing,
	});

	final HeroModel hero;
	final VoidCallback onTap;
	final Widget? trailing;

	@override
	Widget build(BuildContext context) {
		final urls = hero.displayImageCandidates;

		return Card(
			clipBehavior: Clip.antiAlias,
			child: InkWell(
				onTap: onTap,
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.stretch,
					children: <Widget>[
						Expanded(
							child: Stack(
								fit: StackFit.expand,
								children: <Widget>[
									HeroImage(
										urls: urls,
										heroId: hero.id,
										heroName: hero.name,
										searchTerms: hero.imageSearchTerms,
										fit: BoxFit.cover,
										loading: const Center(
											child: CircularProgressIndicator(strokeWidth: 2),
										),
										error: const ColoredBox(
											color: Colors.black12,
											child: Icon(Icons.broken_image, size: 48),
										),
									),
									Positioned.fill(
										child: DecoratedBox(
											decoration: BoxDecoration(
												gradient: LinearGradient(
													begin: Alignment.topCenter,
													end: Alignment.bottomCenter,
													colors: <Color>[
														Colors.black.withValues(alpha: 0.0),
														Colors.black.withValues(alpha: 0.35),
														Colors.black.withValues(alpha: 0.78),
													],
													stops: const <double>[0.45, 0.68, 1],
												),
											),
										),
									),
									Positioned(
										left: 8,
										right: 8,
										bottom: 8,
										child: Column(
											mainAxisSize: MainAxisSize.min,
											children: <Widget>[
												Text(
													hero.name.toUpperCase(),
													textAlign: TextAlign.center,
													maxLines: 1,
													overflow: TextOverflow.ellipsis,
													style: const TextStyle(
														color: Colors.white,
														fontSize: 14,
														fontWeight: FontWeight.w800,
														letterSpacing: 0.5,
														shadows: <Shadow>[
															Shadow(
																color: Colors.black54,
																blurRadius: 5,
															),
														],
													),
												),
												const SizedBox(height: 6),
												Row(
													mainAxisAlignment: MainAxisAlignment.spaceBetween,
													children: <Widget>[
														_StatPentagon(
															value: hero.maxHp,
															fillColor: Colors.red.shade700,
														),
														_StatPentagon(
															value: hero.defense,
															fillColor: Colors.blue.shade700,
														),
													],
												),
											],
										),
									),
								],
							),
						),
						Padding(
							padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
							child: Row(
								children: <Widget>[
									Expanded(
										child: Text(
											hero.publisher,
											maxLines: 1,
											overflow: TextOverflow.ellipsis,
											style: Theme.of(context).textTheme.bodySmall,
										),
									),
									trailing ?? const SizedBox.shrink(),
								],
							),
						),
					],
				),
			),
		);
	}
}

class _StatPentagon extends StatelessWidget {
	const _StatPentagon({
		required this.value,
		required this.fillColor,
	});

	final int value;
	final Color fillColor;

	@override
	Widget build(BuildContext context) {
		final textStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
						color: Colors.white,
						fontWeight: FontWeight.w700,
					) ??
					const TextStyle(
						color: Colors.white,
						fontWeight: FontWeight.w700,
						fontSize: 10,
					);

		return Column(
			mainAxisSize: MainAxisSize.min,
			children: <Widget>[
				CustomPaint(
					painter: _PentagonPainter(fillColor: fillColor),
					child: SizedBox(
						width: 46,
						height: 46,
						child: Center(
							child: Text(
								value.toString(),
								style: textStyle.copyWith(fontSize: 12.5),
							),
						),
					),
				),
			],
		);
	}
}

class _PentagonPainter extends CustomPainter {
	_PentagonPainter({required this.fillColor});

	final Color fillColor;

	@override
	void paint(Canvas canvas, Size size) {
		final center = Offset(size.width / 2, size.height / 2);
		final radius = math.min(size.width, size.height) / 2;
		final path = Path();

		for (var i = 0; i < 5; i++) {
			final angle = -math.pi / 2 + (2 * math.pi * i / 5);
			final point = Offset(
				center.dx + radius * math.cos(angle),
				center.dy + radius * math.sin(angle),
			);
			if (i == 0) {
				path.moveTo(point.dx, point.dy);
			} else {
				path.lineTo(point.dx, point.dy);
			}
		}
		path.close();

		final fill = Paint()..color = fillColor;
		final stroke = Paint()
			..color = Colors.white.withValues(alpha: 0.75)
			..style = PaintingStyle.stroke
			..strokeWidth = 1.4;

		canvas.drawPath(path, fill);
		canvas.drawPath(path, stroke);
	}

	@override
	bool shouldRepaint(covariant _PentagonPainter oldDelegate) {
		return oldDelegate.fillColor != fillColor;
	}
}

