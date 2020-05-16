# janet-notion-helper

## Prerequisite

```
$ brew install janet
$ git clone https://github.com/heycalmdown/janet-notion-helper.git
$ cd janet-notion-helper
$ jpm deps
```

## 사용법

* 노션 토큰을 구하세요
* 콜렉션이 들어 있는 페이지 아이디를 구하세요
  * `https://www.notion.so/4044898e951546df9fadbbba4d98c10f?v=59575ce5af824944a6bc7bd95a14704e` => `4044898e951546df9fadbbba4d98c10f`
* 환경변수 `NOTION_TOKEN=xyz... PAGE_ID=404489...`를 넣어주세요
* `janet main.janet`

```
$ janet main.janet
...
하드씽
소프트웨어, 누가 이렇게 개떡같이 만든 거야
둠
레드셔츠
위대한 게임의 탄생 2
한국인 코드
끔찍하게 헌신적인 덱스터
정신분석적 진단
나미야 잡화점의 기적
```