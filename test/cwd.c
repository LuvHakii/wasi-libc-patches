#include <stdio.h>
#include <unistd.h>

int main(void) {
	char buf[256];
	printf("getcwd=%s\n", getcwd(buf, sizeof buf));
	FILE *f = fopen("hello.txt", "r");
	if (!f) {
		puts("open=FAIL");
		return 1;
	}
	char line[64] = {0};
	fgets(line, sizeof line, f);
	printf("open=%s", line);
	return 0;
}
