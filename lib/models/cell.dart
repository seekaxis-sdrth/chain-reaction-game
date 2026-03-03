class Cell {
  int orbs;
  int? owner;

  Cell({this.orbs = 0, this.owner});

  Cell copyWith({int? orbs, int? owner, bool clearOwner = false}) {
    return Cell(
      orbs: orbs ?? this.orbs,
      owner: clearOwner ? null : (owner ?? this.owner),
    );
  }

  bool get isEmpty => orbs == 0;
}
