#include <stdarg.h>
#include <stdio.h>
#include <unistd.h>

int pscanf(const char *path, const char *fmt, ...) {

	FILE *fd;
	va_list ap;
	int n;

	if (!(fd = fopen(path, "r"))) {
		perror("Couldn't open /proc/stat\n");
		return -1;
	}

	va_start(ap, fmt);
	n = vfscanf(fd, fmt, ap);
	va_end(ap);
	fclose(fd);

	return (n == EOF) ? -1 : n;

}

int main() {
	
	long double a[7], b[7], sum;
	int cpu_perc;
		
	/* cpu user nice system idle iowait irq softirq */
	if (pscanf("/proc/stat", "%*s %Lf %Lf %Lf %Lf %Lf %Lf %Lf",
	           &b[0], &b[1], &b[2], &b[3], &b[4], &b[5], &b[6]) != 7) {
		return -1;
	}
	
	sleep(1);

	/* cpu user nice system idle iowait irq softirq */
	if (pscanf("/proc/stat", "%*s %Lf %Lf %Lf %Lf %Lf %Lf %Lf",
		       &a[0], &a[1], &a[2], &a[3], &a[4], &a[5], &a[6]) != 7) {
		return -1;
	}

	sum = (b[0] + b[1] + b[2] + b[3] + b[4] + b[5] + b[6]) -
	      (a[0] + a[1] + a[2] + a[3] + a[4] + a[5] + a[6]);

	cpu_perc = (int)(100 * ((b[0] + b[1] + b[2] + b[5] + b[6]) -
							 (a[0] + a[1] + a[2] + a[5] + a[6])) / sum);

	printf("%i\n", cpu_perc);

	return 0;

}
