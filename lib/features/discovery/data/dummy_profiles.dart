import 'package:dately/features/discovery/domain/profile.dart';

const List<Profile> dummyProfiles = [
  Profile(
    id: '1',
    name: 'Sarah',
    age: 24,
    bio:
        'Photographer and coffee addict. Looking for someone to explore the city with.',
    location: 'Brooklyn',
    distanceMiles: 2,
    imageUrls: [
      'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=800&h=1200&fit=crop',
    ],
    interests: ['Photography', 'Hiking', 'Coffee Lover'],
    isVerified: true,
  ),
  Profile(
    id: '2',
    name: 'Jessica',
    age: 26,
    bio:
        'Art lover, museum hopper, and wine enthusiast. creative soul looking for inspiration.',
    location: 'Manhattan',
    distanceMiles: 4,
    imageUrls: [
      'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=800&h=1200&fit=crop',
    ],
    interests: ['Art', 'Museums', 'Wine'],
    isVerified: false,
  ),
  Profile(
    id: '3',
    name: 'Emily',
    age: 22,
    bio: 'Student by day, gamer by night. Let\'s play CoD or go for a run.',
    location: 'Queens',
    distanceMiles: 8,
    imageUrls: [
      'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800&h=1200&fit=crop',
    ],
    interests: ['Gaming', 'Running', 'Movies'],
    isVerified: true,
  ),
  Profile(
    id: '4',
    name: 'Olivia',
    age: 25,
    bio: 'Traveler and foodie. I know the best sushi spots in town.',
    location: 'Jersey City',
    distanceMiles: 12,
    imageUrls: [
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800&h=1200&fit=crop',
    ],
    interests: ['Travel', 'Sushi', 'Music'],
    isVerified: false,
  ),
  Profile(
    id: '5',
    name: 'Sophia',
    age: 23,
    bio: 'Dog mom to a golden retriever. Easy going and loves a good laugh.',
    location: 'Staten Island',
    distanceMiles: 15,
    imageUrls: [
      'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=800&h=1200&fit=crop',
    ],
    interests: ['Dogs', 'Comedy', 'Beach'],
    isVerified: true,
  ),
  Profile(
    id: '6',
    name: 'Mia',
    age: 27,
    bio:
        'Yoga instructor and wellness coach. Looking for positive vibes and good energy.',
    location: 'Brooklyn',
    distanceMiles: 3,
    imageUrls: [
      'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?w=800&h=1200&fit=crop',
    ],
    interests: ['Yoga', 'Wellness', 'Meditation'],
    isVerified: true,
  ),
  Profile(
    id: '7',
    name: 'Ava',
    age: 24,
    bio: 'Marketing professional with a passion for brunch and rooftop bars.',
    location: 'Manhattan',
    distanceMiles: 5,
    imageUrls: [
      'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=800&h=1200&fit=crop',
    ],
    interests: ['Brunch', 'Marketing', 'Cocktails'],
    isVerified: false,
  ),
  Profile(
    id: '8',
    name: 'Isabella',
    age: 28,
    bio:
        'Bookworm and tea enthusiast. Let\'s discuss our favorite novels over chai.',
    location: 'Williamsburg',
    distanceMiles: 6,
    imageUrls: [
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=800&h=1200&fit=crop',
    ],
    interests: ['Reading', 'Tea', 'Writing'],
    isVerified: true,
  ),
  Profile(
    id: '9',
    name: 'Charlotte',
    age: 25,
    bio: 'Fitness junkie and smoothie bowl addict. Gym partner wanted!',
    location: 'Queens',
    distanceMiles: 7,
    imageUrls: [
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800&h=1200&fit=crop',
    ],
    interests: ['Fitness', 'Health', 'Nutrition'],
    isVerified: false,
  ),
  Profile(
    id: '10',
    name: 'Amelia',
    age: 26,
    bio: 'Musician and concert lover. Always looking for the next live show.',
    location: 'East Village',
    distanceMiles: 4,
    imageUrls: [
      'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=800&h=1200&fit=crop',
    ],
    interests: ['Music', 'Concerts', 'Guitar'],
    isVerified: true,
  ),
  Profile(
    id: '11',
    name: 'Harper',
    age: 23,
    bio:
        'Fashion designer with an eye for vintage finds. Thrift store adventures?',
    location: 'SoHo',
    distanceMiles: 5,
    imageUrls: [
      'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?w=800&h=1200&fit=crop',
    ],
    interests: ['Fashion', 'Vintage', 'Design'],
    isVerified: false,
  ),
  Profile(
    id: '12',
    name: 'Evelyn',
    age: 29,
    bio:
        'Entrepreneur and startup enthusiast. Building the future, one idea at a time.',
    location: 'Financial District',
    distanceMiles: 8,
    imageUrls: [
      'https://images.unsplash.com/photo-1489424731084-a5d8b219a5bb?w=800&h=1200&fit=crop',
    ],
    interests: ['Startups', 'Tech', 'Networking'],
    isVerified: true,
  ),
  Profile(
    id: '13',
    name: 'Abigail',
    age: 24,
    bio: 'Dance teacher who loves salsa nights. Let\'s dance the night away!',
    location: 'Harlem',
    distanceMiles: 9,
    imageUrls: [
      'https://images.unsplash.com/photo-1502823403499-6ccfcf4fb453?w=800&h=1200&fit=crop',
    ],
    interests: ['Dance', 'Salsa', 'Music'],
    isVerified: false,
  ),
  Profile(
    id: '14',
    name: 'Ella',
    age: 27,
    bio: 'Baker and pastry chef. Sweet tooth? I\'ve got you covered.',
    location: 'Chelsea',
    distanceMiles: 6,
    imageUrls: [
      'https://images.unsplash.com/photo-1500917293891-ef795e70e1f6?w=800&h=1200&fit=crop',
    ],
    interests: ['Baking', 'Desserts', 'Coffee'],
    isVerified: true,
  ),
  Profile(
    id: '15',
    name: 'Scarlett',
    age: 25,
    bio:
        'Adventure seeker and rock climber. Life is too short to stay on the ground.',
    location: 'Brooklyn Heights',
    distanceMiles: 4,
    imageUrls: [
      'https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91?w=800&h=1200&fit=crop',
    ],
    interests: ['Climbing', 'Adventure', 'Travel'],
    isVerified: true,
  ),
];
