/*
before we use logger...
put following command in terminal to install logger lib
=> dart pub add logger
now we can use logger!
*/
//import logger lib
import 'package:logger/logger.dart';


var logger = Logger();

// 실행해서 logger 디자인 보기
void main() {
  demo();
}

void demo() {
  // some situation we use dic type
  // 장문의 메세지, verbose의 약어
  logger.v({'key': 5, 'value': 'something'});

  // debug의 약어
  logger.d('','hif');

  // info의 약어
  logger.i('Info message');

  // warning의 약어
  logger.w('Just a warning!');

  // error의 약어
  logger.e('Error! Something bad happened', 'Test Error');

  // what the fuck의 약어
  logger.wtf('what the fuck','something wrong?');
}
/*
그래서 사용법은 다음과 같다.
logger.[로거의 종류]([메인메세지],[위에 나오는 메세지])는 logger의 형식이므로
우리는 [메인메시지]에는 로거를 통해 알려주려고 하는 데이터를 넣고
[위에 나오는 메세지]에는 메제지의 종류 혹은 설명을 넣도록 하자
 */
