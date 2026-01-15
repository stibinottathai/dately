import 'package:dately/features/discovery/domain/profile.dart';
import 'package:dately/features/likes/domain/like.dart';

final List<Like> dummyLikes = [
  // Received Likes
  Like(
    id: 'like_1',
    profile: const Profile(
      id: '101',
      name: 'Sarah',
      age: 24,
      bio: 'Traveling, Coffee, Dogs',
      location: 'Brooklyn',
      distanceMiles: 2,
      imageUrls: [
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDuIuqNN_HtUpnQ8CBwoSIf6GL7bNkkpP10qHNQm7JkHSmGFgzfOF-7unnisug_VunEvp7ZVxNbnju8PBTTas4Vbm-2ILvkucnuevGwijTPG2E_VZeAYK1Iwe7nNybRd0zvdqsCc0hCxXjDJ7uU0hugGb71twx4uZJGtpTnYyzaL1kTFkjWIDXKeMSa88KadA7nS_8DvagaqKQW-srxCUCdGvfkQnpPHc-RDRLZz0NrigEIBrJBQxesaJTLBzBaJHqfc1KSpNNFHMM',
      ],
      interests: ['Traveling', 'Coffee', 'Dogs'],
      isVerified: true,
    ),
    type: LikeType.regular,
    direction: LikeDirection.received,
    timestamp: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  Like(
    id: 'like_2',
    profile: const Profile(
      id: '102',
      name: 'Jessica',
      age: 22,
      bio: 'Art, Music, Hiking',
      location: 'Manhattan',
      distanceMiles: 4,
      imageUrls: [
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDi-Nbdz5WJ_J5x7pvSO417RKCsqjYFXG5jqGRhtKmcGQtGPUD4eJn80QriHNgUIyjepLAkPh8sJn7uxszvNcHqhDTpMK5jTS6thS7X00M8c6Pm7yNMwspnceE6xvCKauDAVj7-SAoXNVH2kcXKou7vAgM4NtV6sY3tCYWIVQXeGo4zWlZCc_EbzeYL1gKJUEZ9VlQuBIBPDdhl5aLsECKdExNV_kzG3uUWKKlSoFVitvQwSf7ldrIgnVFnnTNGjCgnNzkV7GnVRXA',
      ],
      interests: ['Art', 'Music', 'Hiking'],
      isVerified: false,
    ),
    type: LikeType.regular,
    direction: LikeDirection.received,
    timestamp: DateTime.now().subtract(const Duration(hours: 5)),
  ),

  // Sent Likes
  Like(
    id: 'like_3',
    profile: const Profile(
      id: '103',
      name: 'Emily',
      age: 26,
      bio: 'Adventure seeker and coffee lover',
      location: 'Queens',
      distanceMiles: 8,
      imageUrls: [
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBqPPLsTWbQCnbxrvQTgy6qg_JjxA6mOm_wVc-5q0WBriUmFkbIsNZaoGjNMnz8kbtxlUpzhSluB8uxo9sfq3K0KYlcekayToTWPZuAa5j793EHqUApj72v2QAXS9VGz8xFyMPU8wyejdZ-dAE7s-o81IBAnDDUZWuhXEMHO7dUv5_ygqUe_8ii5o4SxROc2nAgfVaDYhyEHAMAMJcA3_S2OgwqHTh2dN1j88Q35JzEY6XqmnV1swS0G9D15zwEDtBC1rHxczbCoiU',
      ],
      interests: ['Adventure', 'Coffee', 'Photography'],
      isVerified: true,
    ),
    type: LikeType.superLike,
    direction: LikeDirection.sent,
    timestamp: DateTime.now().subtract(const Duration(days: 1)),
  ),
  Like(
    id: 'like_4',
    profile: const Profile(
      id: '104',
      name: 'Mia',
      age: 23,
      bio: 'Dancing, Tacos, Movies',
      location: 'Brooklyn',
      distanceMiles: 3,
      imageUrls: [
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBZ1OtWEJILSM1wXM2TAdUJSLDguaeZaXp3KTkOrHwa87QGxZs0QSedH9Qy8b82Cl_XmrHgEwuD1U80xUahe-z1vTggaX_l4zhw2eR-gBntmYuxYJonG0uuNdinS_kcqQQ_aDvnHkZat8cddO5bM2RlF127Jr-kE8rgfTDLTlJIUEIr5Rmxx11MR3cRvnMcYLuAXNSAQsRhSZWZl_hO0fAbbJ3R7HMJ-h3qIW_gx6ZEPCGXWH_wAxj_HfQGbMs4ndUPEYBWGNqmVcc',
      ],
      interests: ['Dancing', 'Tacos', 'Movies'],
      isVerified: false,
    ),
    type: LikeType.regular,
    direction: LikeDirection.sent,
    timestamp: DateTime.now().subtract(const Duration(days: 2)),
  ),
  Like(
    id: 'like_5',
    profile: const Profile(
      id: '105',
      name: 'Olivia',
      age: 25,
      bio: 'Yoga enthusiast and foodie',
      location: 'Manhattan',
      distanceMiles: 5,
      imageUrls: [
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800&h=1200&fit=crop',
      ],
      interests: ['Yoga', 'Food', 'Wellness'],
      isVerified: true,
    ),
    type: LikeType.regular,
    direction: LikeDirection.received,
    timestamp: DateTime.now().subtract(const Duration(hours: 8)),
  ),
  Like(
    id: 'like_6',
    profile: const Profile(
      id: '106',
      name: 'Sophia',
      age: 27,
      bio: 'Book lover and tea enthusiast',
      location: 'Queens',
      distanceMiles: 6,
      imageUrls: [
        'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?w=800&h=1200&fit=crop',
      ],
      interests: ['Reading', 'Tea', 'Writing'],
      isVerified: false,
    ),
    type: LikeType.regular,
    direction: LikeDirection.sent,
    timestamp: DateTime.now().subtract(const Duration(days: 3)),
  ),
];
