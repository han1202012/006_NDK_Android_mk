#include <jni.h>

extern int test();
//extern int add(int a, int b);

/*void Java_kim_hsl_mk_MainActivity_nativeTest(){
    test();
    //add(1, 2);
}*/

JNIEXPORT void JNICALL
Java_kim_hsl_mk_MainActivity_nativeTest(JNIEnv *env, jobject instance) {

    test();
    //add(1, 2);

}