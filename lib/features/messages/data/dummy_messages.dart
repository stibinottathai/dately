import 'package:dately/features/discovery/domain/profile.dart';
import 'package:dately/features/messages/domain/conversation.dart';
import 'package:dately/features/messages/domain/message.dart';

// Sample profiles for conversations
final _jessicaProfile = const Profile(
  id: 'user_jessica',
  name: 'Jessica',
  age: 24,
  bio: 'Art lover and museum hopper',
  location: 'Manhattan',
  distanceMiles: 4,
  imageUrls: [
    'https://lh3.googleusercontent.com/aida-public/AB6AXuBXBfM8WQNqqsP6QPTietHaqEEzFhlhVqkZCJ2MghOVbhhv8t1EaZCii-EWghzZrUx-fc0Ij5WiglUVpISiAbeC884NlpccAGRKAKkd89wXm3kPLJ2r0Qf9U73CWiXNN0LIlKxCqODWQ1myxKZ_7Cq2Bjsrdme0z8idXlxhSN9TF4bTHsTWPCKobE3nkzqwCjUO1sfLvrqvrIbfy68aVtWj2SW1C-b0VyGPUac2xnHspSX7V9Z0kP2OquOaeFWgrqDRaxOR90SgcQ0',
  ],
  interests: ['Art', 'Museums', 'Wine'],
  isVerified: true,
);

final _liamProfile = const Profile(
  id: 'user_liam',
  name: 'Liam',
  age: 27,
  bio: 'Food enthusiast',
  location: 'Brooklyn',
  distanceMiles: 3,
  imageUrls: [
    'https://lh3.googleusercontent.com/aida-public/AB6AXuCb36tp2cjoUdcyQgD4-zs3AaUcIkdwV1oV-bpc8IEcpB0xBsU3C_pC5-bJr33PXygdqDxC5A7LP0WaqvusF7TGHZOw5-mKQhpycMy4jt8sGd4Sk11bPvLGEtXGx-kaLYtmHNPv02kYOE7s4CjVrNgvzoazr-X_s-udtIzUooYFvxkwdz7K-fvcAO-IGSye4yDpTT3_thj08Hy9Sn36cEM0GYvyaUXuzNRWdB-R-Ux_AlLDTAF2bzh7I7bTAdQomVwZYmPt3-QNFxc',
  ],
  interests: ['Food', 'Cooking', 'Travel'],
  isVerified: false,
);

final _sophiaProfile = const Profile(
  id: 'user_sophia',
  name: 'Sophia',
  age: 23,
  bio: 'Book lover',
  location: 'Queens',
  distanceMiles: 6,
  imageUrls: [
    'https://lh3.googleusercontent.com/aida-public/AB6AXuAnEeLSPRLWupfGTtvzPLYWqCNNzwYa7esem6obWzrlhlwD7uG3kYRAQaWJPj4g0GgCdgvZZU3F1oVdIgIBLoCzkpznB_X1-BtIQKv2yJ_hzqzqzxLISTGnIwuRfuMFLT0yDEy8sjuWV7F-kZO_thX4sWISMQXMRmOFFR-WDWxupKQljeAu9I7Ds_BjfgH70NKiRTlugE6jzGDNKWe6E4YPvYvTiufYILK7hPYGnbe09hH-5GWd9e-qMfeI5gr14iSvyLmgWLzOCn0',
  ],
  interests: ['Reading', 'Tea', 'Writing'],
  isVerified: true,
);

final _alexProfile = const Profile(
  id: 'user_alex',
  name: 'Alex',
  age: 26,
  bio: 'Fitness enthusiast',
  location: 'Manhattan',
  distanceMiles: 5,
  imageUrls: [
    'https://lh3.googleusercontent.com/aida-public/AB6AXuD7wkZfsMlY9yR7_jvfI8Fhl006gguAi4EwVq2rmYjsumu_-XfncK5dZMn6Lilxv0AZBKOWWhEyCQpJUtaSNSZIvuPi4tk6rEQVdo3ryVUg_zrN0zRWT3UgZlwn9eJWAMdB2S3sn1xm9yAPQdjP2apH7CRWTbAkAQ_hVILI9G-Jntd9lnrlGfK2t6oMzKOhrMsGw1kGQTOM0AocfgugMdZCb0mh-ycAnPrvcDTeEO-0zUfup4M6A2VIoWBWKzn-flRBLGhO-gNi68o',
  ],
  interests: ['Gym', 'Running', 'Nutrition'],
  isVerified: true,
);

final _mayaProfile = const Profile(
  id: 'user_maya',
  name: 'Maya',
  age: 25,
  bio: 'Creative soul',
  location: 'Brooklyn',
  distanceMiles: 2,
  imageUrls: [
    'https://lh3.googleusercontent.com/aida-public/AB6AXuCTQ1ro1EVn4q1nvrLf34RkBftTfmIix7_Ytxqs7IvG72oLUdAZB4idEy87Y6FJhtI02EZwmmpDYJYlr8IzYuFBoknFy2quQ2CU3n4WmzEMsXuWRzncxrdBB3b4g95sI3EfxMEWWl7LR_uIt6YRgS3-AJMR2uDiRgHpJZUzF3RK_rbRtBVafR8xVVokEIJHYrIGG9TOlQT44PHvroiSWRq9lru-k5_cSOfQoR_b2Flv0UX6M9-9qB_GYWThwaKTCnBMJxpvA6Xt6F8',
  ],
  interests: ['Photography', 'Design', 'Art'],
  isVerified: false,
);

// New matches
final _sarahProfile = const Profile(
  id: 'user_sarah',
  name: 'Sarah',
  age: 24,
  bio: 'Adventure seeker',
  location: 'Manhattan',
  distanceMiles: 3,
  imageUrls: [
    'https://lh3.googleusercontent.com/aida-public/AB6AXuC2rHldMjOQehdMDzdAsXFuKG41rE8fISuBPDF7EGVNqq3UPnG-MdFmLjWjF3B0jXrqfZyknrWZEY0Kpx_mY-3vqfJaxIoS856EhN2wS--PqiejP1kwv1W5b5RwnNxtcbAs_tdRcqtYTLecUwHJLtbUZfOzaCUjzpQ16hvi8273Z9v8bOUUtEw2wa9l_30yPkcR-vARvT_Zkd1723oIF5MVlPZqlwxdLEvBeQlq1RBHmblZFToX-Xx_ucRORAtTaU6o3uxvjGKxmUk',
  ],
  interests: ['Hiking', 'Photography', 'Travel'],
  isVerified: true,
);

final _mikeProfile = const Profile(
  id: 'user_mike',
  name: 'Mike',
  age: 28,
  bio: 'Tech professional',
  location: 'Brooklyn',
  distanceMiles: 4,
  imageUrls: [
    'https://lh3.googleusercontent.com/aida-public/AB6AXuBuiSGSfL8PL3-ytw4dzIeSPSjs0qKlX9wJzRTQXvXNDJZu4jVWNawY4XZkpzENIJxUTSwbKl4EtJZGI4fd3OYmNRIeLz-Jhf1ZNZMJKXRyKThJ_tp1IKyQa7E7GVKlAcDw1o7pwdidj3Amq_4bvFsW5DoUYa3N3d1uYBb6A0ld-8FezyUYXTGLUOuATyXcc-zUiY4eoewis4hRqqvkXQ43yWwAlgem22W3oszanDhXaTuBS1mRAPNisqG5lcUGi9t_W5QANsP5rcM',
  ],
  interests: ['Tech', 'Gaming', 'Coffee'],
  isVerified: true,
);

final _emmaProfile = const Profile(
  id: 'user_emma',
  name: 'Emma',
  age: 22,
  bio: 'Student and artist',
  location: 'Queens',
  distanceMiles: 7,
  imageUrls: [
    'https://lh3.googleusercontent.com/aida-public/AB6AXuAvqk01r0CiBfvVfT8-U_rZhAYgO59cORqGqBW2-75h9AIrrwIwXgXW0fiFRn3Vwlf45n1C2qIgRophMXasQvKCuPsJwYPfFhZe7KiLWNLuHm4NBkhkEaE-3cppMw7RNhw1EH_5xgZMvjUuuk4iEuZ5db8y8bUQOrU4bj36t97aDF4WSuYuv_5bisPOi_Djr3i-tqHPxQbi3gNVznHGi7Uto094Tu5ozLOGHp0-0JuJALDLseM1LA0WlNeiEhfn3MFeMgr23F8m8N4',
  ],
  interests: ['Art', 'Music', 'Dancing'],
  isVerified: false,
);

final _davidProfile = const Profile(
  id: 'user_david',
  name: 'David',
  age: 29,
  bio: 'Entrepreneur',
  location: 'Manhattan',
  distanceMiles: 2,
  imageUrls: [
    'https://lh3.googleusercontent.com/aida-public/AB6AXuDnDb9aPtrAbaAUA3Fz0KUK9gbU1mJiMVYyAjQH2fJ--hJQju-iMuzOQ1GDxf9QHmvuYz2EI2QCoFoz2XtLMHZ9jsZ6JGmV6NLhruej6HOrWxVEPJZa5BGb4XEZiq00chK6JitlumBNI-4cNDaaojAgckWjDRYwHtlejhLJdgegi_YpKJQ7jSKedbg0lG0YMh5QjIl71JHDP_qccFcbS2qlWvejlHfwDTMRaTXRpLmAdTORoVui-HC4gMgZJITw01oN79U7iR8L_Ao',
  ],
  interests: ['Business', 'Fitness', 'Travel'],
  isVerified: true,
);

final _chloeProfile = const Profile(
  id: 'user_chloe',
  name: 'Chloe',
  age: 23,
  bio: 'Dancer',
  location: 'Brooklyn',
  distanceMiles: 5,
  imageUrls: [
    'https://lh3.googleusercontent.com/aida-public/AB6AXuCn6GiNgx0MQSd8mO2bw4BMj5QS-cloncCjveIk8JKCeckv6PU1e9kXrvlvnW-eVGO5hus8kLfJvHMwDAwo5i3IukDCdbAxAOiMccit-cFT6C2UDduwaIQArR7TpOv-hA-nb1sXf0M7e7sXAqy5_fPTAR53pWBwop3pcS1WooAvrXBmC-DJPk8M6VMcgM3W4OEcFNl9iJ_-RbhTnrQQU1U0xSYKjUO94XlPtyPGC37UTmCa0-SoEvQLjoTwnUDRH_qP6V7Fdnk_Q7E',
  ],
  interests: ['Dance', 'Music', 'Yoga'],
  isVerified: false,
);

// Dummy conversations
final List<Conversation> dummyConversations = [
  Conversation(
    id: 'conv_jessica',
    otherUser: _jessicaProfile,
    lastMessage: Message(
      id: 'msg_jessica_1',
      conversationId: 'conv_jessica',
      senderId: _jessicaProfile.id,
      receiverId: 'me',
      content: "Hey, how's your weekend going...",
      timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
      status: MessageStatus.read,
      isSentByMe: false,
    ),
    unreadCount: 1,
    isOnline: true,
    lastActiveTime: DateTime.now(),
  ),
  Conversation(
    id: 'conv_liam',
    otherUser: _liamProfile,
    lastMessage: Message(
      id: 'msg_liam_1',
      conversationId: 'conv_liam',
      senderId: _liamProfile.id,
      receiverId: 'me',
      content: 'That restaurant sounds amazing,...',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      status: MessageStatus.read,
      isSentByMe: false,
    ),
    unreadCount: 0,
    isOnline: false,
    lastActiveTime: DateTime.now().subtract(const Duration(hours: 1)),
  ),
  Conversation(
    id: 'conv_sophia',
    otherUser: _sophiaProfile,
    lastMessage: Message(
      id: 'msg_sophia_1',
      conversationId: 'conv_sophia',
      senderId: _sophiaProfile.id,
      receiverId: 'me',
      content: 'I just finished that book you...',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      status: MessageStatus.read,
      isSentByMe: false,
    ),
    unreadCount: 0,
    isOnline: false,
    lastActiveTime: DateTime.now().subtract(const Duration(hours: 3)),
  ),
  Conversation(
    id: 'conv_alex',
    otherUser: _alexProfile,
    lastMessage: Message(
      id: 'msg_alex_1',
      conversationId: 'conv_alex',
      senderId: 'me',
      receiverId: _alexProfile.id,
      content: 'See you there! 📍',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      status: MessageStatus.read,
      isSentByMe: true,
    ),
    unreadCount: 0,
    isOnline: true,
    lastActiveTime: DateTime.now(),
  ),
  Conversation(
    id: 'conv_maya',
    otherUser: _mayaProfile,
    lastMessage: Message(
      id: 'msg_maya_1',
      conversationId: 'conv_maya',
      senderId: _mayaProfile.id,
      receiverId: 'me',
      content: 'Haha that\'s so funny! 😂',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      status: MessageStatus.read,
      isSentByMe: false,
    ),
    unreadCount: 0,
    isOnline: false,
    lastActiveTime: DateTime.now().subtract(const Duration(days: 1)),
  ),
];

// New matches (for carousel)
final List<Profile> newMatches = [
  _sarahProfile,
  _mikeProfile,
  _emmaProfile,
  _davidProfile,
  _chloeProfile,
];

// Message history for Sarah's conversation
final List<Message> sarahMessages = [
  Message(
    id: 'msg_sarah_1',
    conversationId: 'conv_sarah',
    senderId: _sarahProfile.id,
    receiverId: 'me',
    content:
        'Hey! I loved your photo from the hiking trip. Where was that? 🏔️',
    timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 50)),
    status: MessageStatus.read,
    isSentByMe: false,
  ),
  Message(
    id: 'msg_sarah_2',
    conversationId: 'conv_sarah',
    senderId: 'me',
    receiverId: _sarahProfile.id,
    content:
        'Thanks Sarah! That was actually at Zion National Park last summer. The view from Angel\'s Landing is incredible.',
    timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 46)),
    status: MessageStatus.read,
    isSentByMe: true,
  ),
  Message(
    id: 'msg_sarah_3',
    conversationId: 'conv_sarah',
    senderId: _sarahProfile.id,
    receiverId: 'me',
    content:
        'I\'ve always wanted to go there! Was it a tough climb? I\'m planning a trip for September.',
    timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 45)),
    status: MessageStatus.read,
    isSentByMe: false,
  ),
  Message(
    id: 'msg_sarah_4',
    conversationId: 'conv_sarah',
    senderId: 'me',
    receiverId: _sarahProfile.id,
    content:
        'It\'s definitely a bit of a workout, but totally worth it! I have some more photos I can show you if you\'re interested?',
    timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 44)),
    status: MessageStatus.sent,
    isSentByMe: true,
  ),
];
