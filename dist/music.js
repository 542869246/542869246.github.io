const ap = new APlayer({
    container: document.getElementById('aplayer'),
    fixed: true,
    autoplay: false,
    audio: [
	{
        name: "Canon",
        artist: '纯音乐',
        url: 'http://win.web.ri01.sycdn.kuwo.cn/fc17772b87211fb9172a2fc718ac3e2a/5b604eec/resource/n2/79/49/1012854441.mp3',
        cover: 'http://p1.music.126.net/SwcB5KXJWg98cfEi_B8V9g==/2535473814084205.jpg?param=130y130',
      },
	  {
        name: "River Flows in You",
        artist: 'Yiruma',
        url: 'http://win.web.ri01.sycdn.kuwo.cn/cb174fd932039e87e49ec338888b1930/5b604d72/resource/n1/23/9/2555012133.mp3',
        cover: 'http://p1.music.126.net/8ZRSyI0ZN_4ah8uzsNd1mA==/2324367581169008.jpg?param=130y130',
      },
      {
        name: '惊蛰',
        artist: '音阙诗听/王梓钰',
        url: 'http://www.ytmp3.cn/down/48755.mp3',
        cover: 'http://p1.music.126.net/5MmXpaP9r88tNzExPGMI8Q==/109951163370350985.jpg?param=130y130',
      }
    ]
});


