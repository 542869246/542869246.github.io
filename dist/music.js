const ap = new APlayer({
    container: document.getElementById('aplayer'),
    fixed: true,
    autoplay: false,
    audio: [
	{
        name: "Champagne Ocean",
        artist: 'Ehrling',
        url: 'https://music.163.com/outchain/player?type=2&id=436147067&auto=1&height=66&bg=e8e8e8',
        cover: 'http://p1.music.126.net/3OCOqJx8ABWtsZejHlfTew==/18784056649624787.jpg?param=130y130',
      },
      {
        name: "PDD洪荒之力",
        artist: '徐梦圆',
        url: 'http://up.mcyt.net/?down/39868.mp3',
        cover: 'http://oeff2vktt.bkt.clouddn.com/image/84.jpg',
      },
      {
        name: '惊蛰',
        artist: '音阙诗听/王梓钰',
        url: 'http://www.ytmp3.cn/down/48755.mp3',
        cover: 'http://p1.music.126.net/5MmXpaP9r88tNzExPGMI8Q==/109951163370350985.jpg?param=130y130',
      }
    ]
});


