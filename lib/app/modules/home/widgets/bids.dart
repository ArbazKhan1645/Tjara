// ignore_for_file: non_constant_identifier_names, deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tjara/app/models/products/single_product_model.dart';
import 'package:tjara/app/services/auth/auth_service.dart';

class BidderTable extends StatefulWidget {
  const BidderTable({
    super.key,
    required this.productBids,
    required this.startingPrice,
    required this.bidIncrement,
    required this.winnerID,
    required this.auction_end_time,
    required this.auction_start_time,
  });

  final ProductBids productBids;
  final num startingPrice;
  final num bidIncrement;
  final String winnerID;
  final String auction_start_time;
  final String auction_end_time;

  @override
  State<BidderTable> createState() => _BidderTableState();
}

class _BidderTableState extends State<BidderTable> {
  Timer? _timer;
  DateTime? _endTime;
  Duration _remainingTime = Duration.zero;
  bool _isExpired = false;
  bool _showAllBidders = false;

  static const int _initialVisibleCount = 3;

  @override
  void initState() {
    super.initState();
    _initializeTimer();
  }

  void _initializeTimer() {
    try {
      _endTime = DateTime.parse(widget.auction_end_time).toLocal();
      _updateRemainingTime();
      _startTimer();
    } catch (_) {
      _isExpired = true;
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        _updateRemainingTime();
        setState(() {});
      }
    });
  }

  void _updateRemainingTime() {
    if (_endTime == null) {
      _remainingTime = Duration.zero;
      _isExpired = true;
      return;
    }

    // 🔥 SAME APPROACH (UTC + offset)
    final nowUtc = DateTime.now().toUtc();
    final offset = DateTime.now().timeZoneOffset;
    final difference = _endTime!.difference(nowUtc) + offset;

    if (difference <= Duration.zero) {
      _remainingTime = Duration.zero;
      _isExpired = true;
      _timer?.cancel();
      _timer = null;
    } else {
      _remainingTime = difference;
      _isExpired = false;
    }
  }

  int get _days => _remainingTime.inDays;
  int get _hours => _remainingTime.inHours % 24;
  int get _minutes => _remainingTime.inMinutes % 60;
  int get _seconds => _remainingTime.inSeconds % 60;

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bids = widget.productBids.bids ?? [];
    final sortedBids = [...bids]..sort(
      (a, b) => (b.auctionBidPrice ?? 0).compareTo(a.auctionBidPrice ?? 0),
    );

    final highestBid = widget.productBids.highestBid ?? 0;
    final winnerBid =
        sortedBids.where((e) => e.bidder?.id == widget.winnerID).firstOrNull;

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _auctionStatus(context, winnerBid),
          _topInfoRow(context, highestBid),
          _reserveChip(
            winnerBid == null
                ? false
                : widget.productBids.isReserveMet ??
                    widget.productBids.bids
                        ?.where((b) => b.hasMetReservedPrice == false)
                        .isEmpty ??
                    true,
            highestBid,
          ),
          _biddersList(sortedBids, winnerBid),
        ],
      ),
    );
  }

  // ================= STATUS BAR =================
  Widget _auctionStatus(BuildContext context, Bid? winnerBid) {
    if (!_isExpired) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: const BoxDecoration(color: Colors.teal),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.timer_outlined, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  'Auction Ends In',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _timeBox(_days, 'Days'),
                _timeSeparator(),
                _timeBox(_hours, 'Hours'),
                _timeSeparator(),
                _timeBox(_minutes, 'Min'),
                _timeSeparator(),
                _timeBox(_seconds, 'Sec'),
              ],
            ),
          ],
        ),
      );
    }

    final bool iAMWinner =
        AuthService.instance.authCustomer?.user != null &&
        winnerBid?.bidder?.id == AuthService.instance.authCustomer?.user?.id;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              winnerBid != null
                  ? [Colors.teal.shade600, Colors.teal.shade400]
                  : [const Color(0xFFfda730), const Color(0xFFf59e0b)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (winnerBid != null)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.emoji_events,
                color: Colors.white,
                size: 20,
              ),
            ),
          if (winnerBid != null) const SizedBox(width: 12),
          Column(
            children: [
              Text(
                winnerBid != null
                    ? "Auction Ended - Winner Selected!"
                    : "⏰ Auction Ended",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              if (iAMWinner) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "🎉 Congratulations! You won!",
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _timeBox(int value, String label) {
    return Container(
      width: 58,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value.toString().padLeft(2, '0'),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _timeSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        ':',
        style: TextStyle(
          color: Colors.white.withOpacity(0.8),
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }

  // ================= TOP INFO =================
  Widget _topInfoRow(BuildContext context, num highestBid) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          _infoChip(
            "Starting Price",
            "\$${widget.startingPrice}",
            Icons.sell_outlined,
          ),
          const SizedBox(width: 8),
          _infoChip(
            "Total Bids",
            "${widget.productBids.totalBids ?? 0}",
            Icons.gavel,
          ),
          const SizedBox(width: 8),
          _infoChip("Increment", "\$${widget.bidIncrement}", Icons.trending_up),
        ],
      ),
    );
  }

  Widget _infoChip(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: Colors.teal),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  Widget _reserveChip(bool met, num highest) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: met ? Colors.teal.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color:
                  met
                      ? Colors.teal.withOpacity(0.15)
                      : Colors.red.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              met ? Icons.check_circle : Icons.cancel,
              color: met ? Colors.teal : Colors.red,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            met ? "Reserve Met" : "Reserve Not Met",
            style: TextStyle(
              color: met ? Colors.teal.shade700 : Colors.red.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: met ? Colors.teal : Colors.red.shade400,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '\$$highest',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= BIDDERS LIST =================
  Widget _biddersList(List<Bid> bids, Bid? winnerBid) {
    if (bids.isEmpty) {
      return Container();
    }

    final hasMoreBids = bids.length > _initialVisibleCount;
    final visibleBids =
        _showAllBidders ? bids : bids.take(_initialVisibleCount).toList();
    final remainingCount = bids.length - _initialVisibleCount;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Bidders',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ),
          Stack(
            children: [
              Column(
                children: [
                  ...List.generate(visibleBids.length, (i) {
                    final bid = visibleBids[i];
                    final isWinner = bid.id == winnerBid?.id;
                    final isLastVisible = i == visibleBids.length - 1;
                    final shouldFade =
                        !_showAllBidders && hasMoreBids && isLastVisible;

                    return _bidderCard(bid, i + 1, isWinner, i, shouldFade);
                  }),
                ],
              ),
              // Show More Overlay
              if (!_showAllBidders && hasMoreBids)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0),
                          Colors.white.withOpacity(0.9),
                          Colors.white,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                    child: Center(child: _showMoreButton(remainingCount)),
                  ),
                ),
            ],
          ),
          // Show Less Button
          if (_showAllBidders && hasMoreBids) Center(child: _showLessButton()),
        ],
      ),
    );
  }

  Widget _showMoreButton(int remainingCount) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _showAllBidders = true),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Colors.teal, Colors.teal]),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.teal.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.expand_more, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                'Show $remainingCount More Bidder${remainingCount > 1 ? 's' : ''}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _showLessButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: TextButton.icon(
        onPressed: () => setState(() => _showAllBidders = false),
        icon: const Icon(Icons.expand_less, size: 20),
        label: const Text('Show Less'),
        style: TextButton.styleFrom(foregroundColor: Colors.grey.shade600),
      ),
    );
  }

  Widget _bidderCard(
    Bid bid,
    int rank,
    bool isWinner,
    int index,
    bool shouldFade,
  ) {
    final isTopBidder = index == 0;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: shouldFade ? 0.4 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color:
              isTopBidder
                  ? Colors.teal.withOpacity(0.08)
                  : isWinner
                  ? const Color(0xFFfda730).withOpacity(0.08)
                  : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isTopBidder
                    ? Colors.teal.withOpacity(0.3)
                    : isWinner
                    ? const Color(0xFFfda730).withOpacity(0.3)
                    : Colors.grey.shade200,
            width: isTopBidder || isWinner ? 1.5 : 1,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 4,
          ),
          leading: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors:
                        isWinner
                            ? [const Color(0xFFfda730), const Color(0xFFf59e0b)]
                            : isTopBidder
                            ? [Colors.teal.shade400, Colors.teal.shade600]
                            : [Colors.grey.shade400, Colors.grey.shade500],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '$rank',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              if (isTopBidder)
                Positioned(
                  top: -6,
                  right: -6,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.star,
                      size: 14,
                      color: Colors.amber.shade600,
                    ),
                  ),
                ),
              if (isWinner)
                Positioned(
                  top: -6,
                  right: -6,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.emoji_events,
                      size: 14,
                      color: Color(0xFFfda730),
                    ),
                  ),
                ),
            ],
          ),
          title: Text(
            bid.bidder?.fullName ?? "Unknown",
            style: TextStyle(
              fontWeight:
                  isTopBidder || isWinner ? FontWeight.w600 : FontWeight.w500,
              fontSize: 15,
            ),
          ),
          subtitle: Row(
            children: [
              Icon(Icons.access_time, size: 12, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text(
                _formatDate(bid.createdAt),
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ],
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color:
                  isWinner
                      ? const Color(0xFFfda730)
                      : isTopBidder
                      ? Colors.teal
                      : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "\$${bid.auctionBidPrice}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color:
                    isWinner || isTopBidder
                        ? Colors.white
                        : Colors.grey.shade700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "-";
    final localDate = date.toLocal(); // UTC → Local
    return DateFormat("dd MMM yyyy, HH:mm").format(localDate);
  }
}
