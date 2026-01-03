#include "../src/librpitx.h"
#include <unistd.h>
#include <fcntl.h>
#include <signal.h>
#include <cstring>
#include <cstdlib>
#include <cstdio>
#include <cstdint>
//runnig bool, basically wide shutdown
bool running = true;

//using it here
static void terminate(int)
{
    running = false;
    fprintf(stderr, "\nStopping transmission...\n");
}
//generate B/W test pattern, for starters
void generate_test_pattern(uint8_t *buf, int width, int height)
{
    for (int y = 0; y < height; y++)
    {
        for (int x = 0; x < width; x++)
        {
            buf[y * width + x] = (uint8_t)(255.0 * x / (width - 1));
        }
    }
}
void tv_transmitter(uint64_t freq, int mode, const char *path)
{
    const int SR = 1000000;
    //frame size, not high quality, but somehow stable
    const int WIDTH = 52;
    const int HEIGHT = 625;
    const int FRAME_SIZE = WIDTH * HEIGHT;

    uint8_t frame[FRAME_SIZE];

    atv atvtest(freq, SR, 14, HEIGHT);
    atvtest.start();

    int fd = -1;
    //input selection - test / 8 bit grayscale image / 8 bit grayscale video
    if (mode == 0) // pattern
    {
        generate_test_pattern(frame, WIDTH, HEIGHT);
    }
    else if (mode == 1) //image
    {
        fd = open(path, O_RDONLY);
        if (fd < 0)
        {
            perror("open");
            return;
        }

        ssize_t r = read(fd, frame, FRAME_SIZE);
        close(fd);

        if (r != FRAME_SIZE)
        {
            fprintf(stderr, "Incorrect image size (%ld bytes)\n", r);
            return;
        }
    }
    else if (mode == 2) //video
    {
        fd = STDIN_FILENO;
    }

    while (running)//handle running at 25 fps
    {
        if (mode == 0 || mode == 1)
        {
            atvtest.SetFrame(frame, HEIGHT);
            usleep(40000); //25fps
        }
        else if (mode == 2)
        {
            ssize_t r = read(fd, frame, FRAME_SIZE);
            if (r <= 0)
                break;
            atvtest.SetFrame(frame, HEIGHT);
        }
    }
}
//main
int main(int argc, char *argv[])
{
    uint64_t freq = 194000000; //default frequency set by author, based on divider setting etc and works best
    int mode = -1;
    const char *path = nullptr;
    //arg parser, set by user, sets mode and frequency
    for (int i = 1; i < argc; i++)
    {
        if (!strcmp(argv[i], "--freq") && i + 1 < argc)
        {
            freq = strtoull(argv[++i], nullptr, 10);
        }
        else if (!strcmp(argv[i], "--pattern"))
        {
            mode = 0;
        }
        else if (!strcmp(argv[i], "--image") && i + 1 < argc)
        {
            mode = 1;
            path = argv[++i];
        }
        else if (!strcmp(argv[i], "--video") && i + 1 < argc)
        {
            mode = 2;
            path = argv[++i];
        }
    }

    if (mode == -1)
    {
        fprintf(stderr,
            "Usage:\n"
            "  testrpitx --pattern [--freq Hz]\n"
            "  testrpitx --image file.gray [--freq Hz]\n"
            "  testrpitx --video - [--freq Hz]\n");
        return 1;
    }

    struct sigaction sa{};
    sa.sa_handler = terminate;
    sigaction(SIGINT,  &sa, nullptr);
    sigaction(SIGTERM, &sa, nullptr);
    sigaction(SIGQUIT, &sa, nullptr);

    dbg_setlevel(1);

    fprintf(stderr, "TV TX @ %llu Hz\n", freq);
    tv_transmitter(freq, mode, path);

    return 0;
}
