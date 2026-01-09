// job_model.dart
import 'package:tjara/app/models/categories/categories_model.dart';

class JobsResponse {
  JobsResponse({
    required this.jobs,
  });

  final JobsPagination jobs;

  factory JobsResponse.fromJson(Map<String, dynamic> json) => JobsResponse(
        jobs: JobsPagination.fromJson(json['jobs'] ?? {}),
      );
}

class JobsPagination {
  JobsPagination({
    required this.currentPage,
    required this.data,
    required this.firstPageUrl,
    required this.from,
    required this.lastPage,
    required this.lastPageUrl,
    required this.links,
    required this.nextPageUrl,
    required this.path,
    required this.perPage,
    required this.prevPageUrl,
    required this.to,
    required this.total,
  });

  final int currentPage;
  final List<Job> data;
  final String firstPageUrl;
  final int from;
  final int lastPage;
  final String lastPageUrl;
  final List<Link> links;
  final String? nextPageUrl;
  final String path;
  final int perPage;
  final String? prevPageUrl;
  final int to;
  final int total;

  factory JobsPagination.fromJson(Map<String, dynamic> json) => JobsPagination(
        currentPage: json['current_page'] ?? 0,
        data: List<Job>.from((json['data'] ?? []).map((x) => Job.fromJson(x))),
        firstPageUrl: json['first_page_url'] ?? '',
        from: json['from'] ?? 0,
        lastPage: json['last_page'] ?? 0,
        lastPageUrl: json['last_page_url'] ?? '',
        links:
            List<Link>.from((json['links'] ?? []).map((x) => Link.fromJson(x))),
        nextPageUrl: json['next_page_url'],
        path: json['path'] ?? '',
        perPage: json['per_page'] ?? 0,
        prevPageUrl: json['prev_page_url'],
        to: json['to'] ?? 0,
        total: json['total'] ?? 0,
      );
}

class Job {
  Job({
    required this.id,
    required this.slug,
    required this.shopId,
    required this.title,
    required this.description,
    required this.thumbnailId,
    required this.salary,
    required this.countryId,
    required this.stateId,
    required this.cityId,
    required this.isFeatured,
    required this.jobType,
    required this.workType,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.thumbnail,
    required this.applications,
    required this.country,
    required this.state,
    required this.city,
  });

  final String id;
  final String slug;
  final String shopId;
  final String title;
  final String description;
  final String thumbnailId;
  final String salary;
  final String countryId;
  final String stateId;
  final String cityId;
  final dynamic isFeatured;
  final String jobType;
  final String workType;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Thumbnail thumbnail;
  final Applications applications;
  final Country country;
  final State state;
  final City city;

  factory Job.fromJson(Map<String, dynamic> json) => Job(
        id: json['id'] ?? '',
        slug: json['slug'] ?? '',
        shopId: json['shop_id'] ?? '',
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        thumbnailId: json['thumbnail_id'] ?? '',
        salary: json['salary'] ?? '',
        countryId: json['country_id'] ?? '',
        stateId: json['state_id'] ?? '',
        cityId: json['city_id'] ?? '',
        isFeatured: json['is_featured'],
        jobType: json['job_type'] ?? '',
        workType: json['work_type'] ?? '',
        status: json['status'] ?? '',
        createdAt:
            DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
        updatedAt:
            DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
        thumbnail: Thumbnail.fromJson(json['thumbnail'] ?? {}),
        applications: Applications.fromJson(json['applications'] ?? {}),
        country: Country.fromJson(json['country'] ?? {}),
        state: State.fromJson(json['state'] ?? {}),
        city: City.fromJson(json['city'] ?? {}),
      );
}

class Applications {
  Applications({
    required this.applications,
  });

  final List<dynamic> applications;

  factory Applications.fromJson(Map<String, dynamic> json) => Applications(
        applications:
            List<dynamic>.from((json['applications'] ?? []).map((x) => x)),
      );
}



class Media {
  Media({
    required this.id,
    required this.url,
    required this.optimizedMediaUrl,
    required this.mediaType,
    required this.isUsed,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String url;
  final String? optimizedMediaUrl;
  final String? mediaType;
  final dynamic isUsed;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory Media.fromJson(Map<String, dynamic> json) => Media(
        id: json['id'] ?? '',
        url: json['url'] ?? '',
        optimizedMediaUrl: json['optimized_media_url'],
        mediaType: json['media_type'],
        isUsed: json['is_used'],
        createdAt:
            DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
        updatedAt:
            DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      );
}

class Country {
  Country({
    required this.id,
    required this.name,
    required this.countryCode,
    required this.currency,
    required this.currencyCode,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String countryCode;
  final String currency;
  final String currencyCode;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory Country.fromJson(Map<String, dynamic> json) => Country(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        countryCode: json['country_code'] ?? '',
        currency: json['currency'] ?? '',
        currencyCode: json['currency_code'] ?? '',
        createdAt:
            DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
        updatedAt:
            DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      );
}

class State {
  State({
    required this.id,
    required this.countryId,
    required this.name,
    required this.isoCode,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String countryId;
  final String name;
  final String? isoCode;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory State.fromJson(Map<String, dynamic> json) => State(
        id: json['id'] ?? '',
        countryId: json['country_id'] ?? '',
        name: json['name'] ?? '',
        isoCode: json['iso_code'],
        createdAt:
            DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
        updatedAt:
            DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      );
}

class City {
  City({
    required this.id,
    required this.stateId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String stateId;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory City.fromJson(Map<String, dynamic> json) => City(
        id: json['id'] ?? '',
        stateId: json['state_id'] ?? '',
        name: json['name'] ?? '',
        createdAt:
            DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
        updatedAt:
            DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      );
}

class Link {
  Link({
    required this.url,
    required this.label,
    required this.active,
  });

  final String? url;
  final String label;
  final bool active;

  factory Link.fromJson(Map<String, dynamic> json) => Link(
        url: json['url'],
        label: json['label'] ?? '',
        active: json['active'] ?? false,
      );
}
