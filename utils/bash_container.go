package main

import (
	"os"
	"fmt"

	"flag"
	"math/rand"
	"time"
	"strings"
	"net/http"
	"encoding/json"
	"io/ioutil"

	"github.com/docker/docker/client"
	"github.com/docker/docker/api/types"
	"github.com/docker/docker/api/types/filters"
	"golang.org/x/net/context"
)

type appS struct{
	Id 		string	`json:"id"`
	AppId string	`json:"appId"`
	Host 	string	`json:"host"`
	State string	`json:"state"`
}

type taskResponse struct{
	TaskR	[]appS	`json:"tasks"`
}


var Master_Mesos = [3]string{"192.168.131.11","192.168.131.12","192.168.131.13"}

const Version = "1.0"

func main(){
	if len(os.Args) < 1{
		fmt.Println("need service-path")
		os.Exit(-1)
	}

	if os.Args[0] == "-v"{
		fmt.Println("Version",Version)
	}

	var (
		svc string
	)
	flag.StringVar(&svc,"svc","","service path on DC/OS: service.group or group/service")
	flag.Parse()

	svcRunning := getRunningAppbyPath(svc)
	if len(svcRunning) > 1 {
		fmt.Println("this service has many instance. you can use this command to bash")
		for _,s := range svcRunning{
			fmt.Println("DOCKER_HOST=",s.Host,":4243", " docker ps -q --filter \"label=MESOS_TASK_ID=",s.Id,"\"")
			fmt.Println("DOCKER_HOST=",s.Host,":4243", " docker exec -ti <container id> bash")
		}
		os.Exit(-1)
	}
	bashIn(svcRunning)
	fmt.Println(svcRunning)
}

func getAppList(){

}

func bashIn(svcRunning []appS){
	if len(svcRunning) < 1{
		return
	}
	fmt.Println(len(svcRunning))
	for _,s := range svcRunning{
		fmt.Println(s)

		env := envToMap()
		defer mapToEnv(env)

		envMap := map[string]string{
			"DOCKER_HOST":        s.Host+":4243",
			"DOCKER_API_VERSION": "1.22",
		}
		mapToEnv(envMap)

		dclient, _ := client.NewEnvClient()
		//defer dclient.Close()
		filter := filters.NewArgs()
		filter.Add("label", "MESOS_TASK_ID="+s.Id)
		containers, _ := dclient.ContainerList(context.Background(), types.ContainerListOptions{
			Size:    true,
			All:     true,
			Since:   "container",
			Filters: filter})
		for _,_ = range containers{
			fmt.Println("test")
		}
	}
}

func getRunningAppbyPath(p string)[]appS{
	if strings.Contains(p,"."){
		fmt.Println("need group/service")
		os.Exit(-1)
	}
	sed := time.Now().Nanosecond()
	master := Master_Mesos[rand.Intn(sed)%3]
	appUrl := strings.Join([]string{master,"marathon","v2/apps",p,"tasks"},"/")

	fmt.Println(appUrl)
	resp, err := http.Get("http://"+appUrl)
	if err != nil{
		fmt.Println("app get error.")
		os.Exit(-1)
	}
	defer resp.Body.Close()

	var data []byte
	data, err = ioutil.ReadAll(resp.Body)
	var appR taskResponse
	err = json.Unmarshal(data,&appR)
	if err != nil{
		fmt.Println("unmarshal error")
	}
	//fmt.Println(string(data))
	//fmt.Println(appR.TaskR)
	return appR.TaskR
}

func mapToEnv(env map[string]string) {
	for k, v := range env {
		os.Setenv(k, v)
	}
}

func envToMap() map[string]string {
	env := make(map[string]string)
	for _, e := range os.Environ() {
		kv := strings.SplitAfterN(e, "=", 2)
		env[kv[0]] = kv[1]
	}

	return env
}
