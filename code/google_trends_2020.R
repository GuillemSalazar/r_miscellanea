library(tidyverse)
library(gtrendsR)

keyword<-c("Wuhan",
           "mascarilla",
           "coronavirus",
           "PCR",
           "confinamiento",
           "estado de alarma",
           "Fase 1",
           "Fase 2",
           "Fase 3",
           "gel hidroalcoholico",
           "ERTE",
           "ingreso mínimo vital",
           "vacuna",
           "pan casero",
           "masa madre",
           "levadura fresca",
           "papel higiénico",
           "Fernando Simón",
           "ZOOM",
           "Skype",
           "Joe Biden",
           "Donald Trump")

res<-NULL
for (i in keyword){
  tmp<-gtrends(keyword = i,geo = "ES",time = "today 12-m",gprop = "web",onlyInterest = T)
  tmp$interest_over_time<-tmp$interest_over_time %>%
    mutate(hits=as.numeric(ifelse(hits=="<1",0,hits)))
  res<-res %>% bind_rows(tmp$interest_over_time)
}

res<-res %>%
  mutate(keyword=fct_reorder(keyword,hits,which.max))

g<-ggplot(data=res,aes(x=date,y=hits)) +
  geom_line(col="white") +
  facet_grid(keyword~.) +
  scale_x_datetime(date_labels = "%m",breaks = as.POSIXct(c("2020-01-15","2020-02-15","2020-03-15","2020-04-15","2020-05-15","2020-06-15","2020-07-15","2020-08-15","2020-09-15","2020-10-15","2020-11-15","2020-12-15"))) +
  xlab("Mes del año") +
  labs(title="2020 en 22 búsquedas",
       subtitle="Búsquedas en Google en España durante 2020 ordenadas por la fecha de máxima atención",
       caption = "Datos derivados de Google Trends (https://trends.google.com/trends/yis/2020/ES/)\nTwitter: @GuillemSalazar") +
  theme(text=element_text(color="white",family="Optima"),
        strip.text.y = element_text(color="white",face = "italic",angle=0,hjust=0,vjust=0.5),
        axis.title.x = element_text(color="white"),
        axis.title.y = element_blank(),
        axis.text.y = element_blank(),
        axis.text.x = element_text(color="white"),
        axis.ticks.y = element_blank(),
        axis.ticks.x = element_line(color="white"),
        rect = element_blank(),
        legend.position = "none",
        plot.background = element_rect(color="black",fill="black"),
        panel.grid = element_blank(),
        plot.title = element_text(face = "bold",size=20),
        plot.title.position = "plot",plot.margin = unit(c(0.3,1,0.3,1),"cm"),
        plot.subtitle = element_text(size=8),
        plot.caption = element_text(size=6),
        plot.caption.position = "plot")
ggsave("../images/2_gogle_trends_2020.png",g,height = unit(8,"cm"),width = unit(5,"cm"))
