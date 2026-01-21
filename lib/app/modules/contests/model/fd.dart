import 'package:tjara/app/modules/contests/model/contest_model.dart';

class ContestsResponse {
  final ContestsPagination? contests;

  ContestsResponse({this.contests});

  factory ContestsResponse.fromJson(Map<String, dynamic> json) {
    return ContestsResponse(
      contests:
          json['contests'] != null
              ? ContestsPagination.fromJson(json['contests'])
              : null,
    );
  }
}

class ContestsPagination {
  final int? currentPage;
  final List<ContestModel>? data;
  final String? firstPageUrl;
  final int? from;
  final int? lastPage;
  final String? lastPageUrl;
  final List<LinkModel>? links;
  final String? nextPageUrl;
  final String? path;
  final int? perPage;
  final String? prevPageUrl;
  final int? to;
  final int? total;

  ContestsPagination({
    this.currentPage,
    this.data,
    this.firstPageUrl,
    this.from,
    this.lastPage,
    this.lastPageUrl,
    this.links,
    this.nextPageUrl,
    this.path,
    this.perPage,
    this.prevPageUrl,
    this.to,
    this.total,
  });

  factory ContestsPagination.fromJson(Map<String, dynamic> json) {
    final List<ContestModel> contestList = [];
    if (json['data'] != null) {
      json['data'].forEach((contest) {
        contestList.add(ContestModel.fromJson(contest));
      });
    }

    final List<LinkModel> linksList = [];
    if (json['links'] != null) {
      json['links'].forEach((link) {
        linksList.add(LinkModel.fromJson(link));
      });
    }

    return ContestsPagination(
      currentPage: json['current_page'],
      data: contestList,
      firstPageUrl: json['first_page_url'],
      from: json['from'],
      lastPage: json['last_page'],
      lastPageUrl: json['last_page_url'],
      links: linksList,
      nextPageUrl: json['next_page_url'],
      path: json['path'],
      perPage: json['per_page'],
      prevPageUrl: json['prev_page_url'],
      to: json['to'],
      total: json['total'],
    );
  }
}

class LinkModel {
  final String? url;
  final String? label;
  final bool? active;

  LinkModel({this.url, this.label, this.active});

  factory LinkModel.fromJson(Map<String, dynamic> json) {
    return LinkModel(
      url: json['url'],
      label: json['label'],
      active: json['active'],
    );
  }
}
