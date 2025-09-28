setwd()

# Library ----

library(tidyverse)
library(janitor)
library(reshape2)
library(ggpubr)
library(ggridges)

# Loading simulation results ----

abm <- read.csv("simulation.csv", skip = 6) %>% clean_names()

# Figure 2. Affective polarization changes for all agents ----

## Low social and low media influence ----
abm_low_low <- abm |>
  filter(global_social_influence == 0.1 & global_media_influence == 0.1)
abm_low_low <- abm_low_low |>
  mutate(condition = case_when(
    global_homogenous_discussion == 0.1 & global_selective_exposure == 0.1 ~ "Low HD/Low SE rates",
    global_homogenous_discussion == 0.1 & global_selective_exposure == 0.9 ~ "Low HD/High SE rates",
    global_homogenous_discussion == 0.9 & global_selective_exposure == 0.1  ~ "High HD/Low SE rates",
    global_homogenous_discussion == 0.9 & global_selective_exposure == 0.9  ~ "High HD/High SE rates"
  ))
abm_low_low$condition <- factor(abm_low_low$condition, levels = c("High HD/Low SE rates","Low HD/High SE rates","High HD/High SE rates","Low HD/Low SE rates"))
abm_low_low <- abm_low_low[order(abm_low_low$x_run_number),]
low_low_sum <- abm_low_low %>% 
  group_by(x_step, condition) %>%
  summarize(mean_affective = mean(mean_affective),
            mean_sd_affective = mean(sd_affective))

figure_lowlow <- ggplot() +
  geom_line(data = abm_low_low, aes(x = x_step, y = mean_affective, group = x_run_number), alpha = 0.5, linewidth = 0.3, color = "grey") +
  geom_line(data = low_low_sum, aes(x = x_step, y = mean_affective, group = condition, color = condition), linewidth = 0.8) +
  labs(x = "Steps", y = "Affective polarization", title = "Low social/Low media influences") +
  ylim(c(4.5,8.5)) +
  theme_bw() +
  theme(text=element_text(family="Times New Roman", face="bold"),
        axis.text = element_text(size = 12),
        axis.title.x = element_text(size = 12),
        axis.title.y = element_text(size = 16),
        title = element_text(size = 16),
        legend.title = element_blank(),
        legend.text = element_text(size = 16),
        legend.position = "bottom") +
  guides(color = guide_legend(nrow = 2))


## High social and high media influence ----
abm_high_high <- abm |>
  filter(global_social_influence == 0.9 & global_media_influence == 0.9)
abm_high_high <- abm_high_high |>
  mutate(condition = case_when(
    global_homogenous_discussion == 0.1 & global_selective_exposure == 0.1 ~ "Low HD/Low SE rates",
    global_homogenous_discussion == 0.1 & global_selective_exposure == 0.9 ~ "Low HD/High SE rates",
    global_homogenous_discussion == 0.9 & global_selective_exposure == 0.1  ~ "High HD/Low SE rates",
    global_homogenous_discussion == 0.9 & global_selective_exposure == 0.9  ~ "High HD/High SE rates"
  ))
abm_high_high$condition <- factor(abm_high_high$condition, levels = c("High HD/Low SE rates","Low HD/High SE rates","High HD/High SE rates","Low HD/Low SE rates"))
abm_high_high <- abm_high_high[order(abm_high_high$x_run_number),]
high_high_sum <- abm_high_high %>% 
  group_by(x_step, condition) %>%
  summarize(mean_affective = mean(mean_affective),
            mean_sd_affective = mean(sd_affective))

figure_highhigh <- ggplot() +
  geom_line(data = abm_high_high, aes(x = x_step, y = mean_affective, group = x_run_number), alpha = 0.5, linewidth = 0.3, color = "grey") +
  geom_line(data = high_high_sum, aes(x = x_step, y = mean_affective, group = condition, color = condition), linewidth = 0.8) +
  labs(x = "Steps", y = "Affective polarization", title = "High social/High media influences") +
  ylim(c(4.5,8.5)) +
  theme_bw() +
  theme(text=element_text(family="Times New Roman", face="bold"),
        axis.text = element_text(size = 12),
        axis.title.x = element_text(size = 12),
        axis.title.y = element_blank(),
        title = element_text(size = 16),
        legend.title = element_blank(),
        legend.text = element_text(size = 16),
        legend.position = "bottom") +
  guides(color = guide_legend(nrow = 2))


## Low social and high media influence ----
abm_low_high <- abm |>
  filter(global_social_influence == 0.1 & global_media_influence == 0.9)
abm_low_high <- abm_low_high |>
  mutate(condition = case_when(
    global_homogenous_discussion == 0.1 & global_selective_exposure == 0.1 ~ "Low HD/Low SE rates",
    global_homogenous_discussion == 0.1 & global_selective_exposure == 0.9 ~ "Low HD/High SE rates",
    global_homogenous_discussion == 0.9 & global_selective_exposure == 0.1  ~ "High HD/Low SE rates",
    global_homogenous_discussion == 0.9 & global_selective_exposure == 0.9  ~ "High HD/High SE rates"
  ))
abm_low_high$condition <- factor(abm_low_high$condition, levels = c("High HD/Low SE rates","Low HD/High SE rates","High HD/High SE rates","Low HD/Low SE rates"))
abm_low_high <- abm_low_high[order(abm_low_high$x_run_number),]
low_high_sum <- abm_low_high %>% 
  group_by(x_step, condition) %>%
  summarize(mean_affective = mean(mean_affective),
            mean_sd_affective = mean(sd_affective))

figure_lowhigh <- ggplot() +
  geom_line(data = abm_low_high, aes(x = x_step, y = mean_affective, group = x_run_number), alpha = 0.5, linewidth = 0.3, color = "grey") +
  geom_line(data = low_high_sum, aes(x = x_step, y = mean_affective, group = condition, color = condition), linewidth = 0.8) +
  labs(x = "Steps", y = "Affective polarization", title = "Low social/High media influences") +
  ylim(c(4.5,8.5)) +
  theme_bw() +
  theme(text=element_text(family="Times New Roman", face="bold"),
        axis.text = element_text(size = 12),
        axis.title.x = element_text(size = 12),
        axis.title.y = element_text(size = 16),
        title = element_text(size = 16),
        legend.title = element_blank(),
        legend.text = element_text(size = 16),
        legend.position = "bottom") +
  guides(color = guide_legend(nrow = 2))


## High social and low media influence ----
abm_high_low <- abm |>
  filter(global_social_influence == 0.9 & global_media_influence == 0.1)
abm_high_low <- abm_high_low |>
  mutate(condition = case_when(
    global_homogenous_discussion == 0.1 & global_selective_exposure == 0.1 ~ "Low HD/Low SE rates",
    global_homogenous_discussion == 0.1 & global_selective_exposure == 0.9 ~ "Low HD/High SE rates",
    global_homogenous_discussion == 0.9 & global_selective_exposure == 0.1  ~ "High HD/Low SE rates",
    global_homogenous_discussion == 0.9 & global_selective_exposure == 0.9  ~ "High HD/High SE rates"
  ))
abm_high_low$condition <- factor(abm_high_low$condition, levels = c("High HD/Low SE rates","Low HD/High SE rates","High HD/High SE rates","Low HD/Low SE rates"))
abm_high_low <- abm_high_low[order(abm_high_low$x_run_number),]
high_low_sum <- abm_high_low %>% 
  group_by(x_step, condition) %>%
  summarize(mean_affective = mean(mean_affective),
            mean_sd_affective = mean(sd_affective))

figure_highlow <- ggplot() +
  geom_line(data = abm_high_low, aes(x = x_step, y = mean_affective, group = x_run_number), alpha = 0.5, linewidth = 0.3, color = "grey") +
  geom_line(data = high_low_sum, aes(x = x_step, y = mean_affective, group = condition, color = condition), linewidth = 0.8) +
  labs(x = "Steps", y = "AP standard deviation", title = "High social/Low media influences") +
  ylim(c(4.5,8.5)) +
  theme_bw() +
  theme(text=element_text(family="Times New Roman", face="bold"),
        axis.text = element_text(size = 12),
        axis.title.x = element_text(size = 12),
        axis.title.y = element_blank(),
        title = element_text(size = 16),
        legend.title = element_blank(),
        legend.text = element_text(size = 16),
        legend.position = "bottom") +
  guides(color = guide_legend(nrow = 2))


## Combine subgraphs into Figure 2 ----

figure2 <- ggarrange(figure_lowlow, figure_highhigh, figure_lowhigh, figure_highlow,
                     nrow=2, ncol=2, common.legend = TRUE, legend="bottom")


# Figure 3. Affective polarization standard deviation changes for all agents ----

## Low social and low media influence ----
figure_lowlow_sd <- ggplot() +
  geom_line(data = abm_low_low, aes(x = x_step, y = sd_affective, group = x_run_number), alpha = 0.5, linewidth = 0.3, color = "grey") +
  geom_line(data = low_low_sum, aes(x = x_step, y = mean_sd_affective , group = condition, color = condition), linewidth = 0.8) +
  labs(x = "Steps", y = "AP standard deviation", title = "Low social/Low media influences") +
  ylim(c(1,4)) +
  theme_bw() +
  theme(text=element_text(family="Times New Roman", face="bold"),
        axis.text = element_text(size = 12),
        axis.title.x = element_text(size = 12),
        axis.title.y = element_text(size = 16),
        title = element_text(size = 16),
        legend.title = element_blank(),
        legend.text = element_text(size = 16),
        legend.position = "bottom") +
  guides(color = guide_legend(nrow = 2))

## High social and high media influence ----
figure_highhigh_sd <- ggplot() +
  geom_line(data = abm_high_high, aes(x = x_step, y = sd_affective, group = x_run_number), alpha = 0.5, linewidth = 0.3, color = "grey") +
  geom_line(data = high_high_sum, aes(x = x_step, y = mean_sd_affective, group = condition, color = condition), linewidth = 0.8) +
  labs(x = "Steps", y = "AP standard deviation", title = "High social/High media influences") +
  ylim(c(1,4)) +
  theme_bw() +
  theme(text=element_text(family="Times New Roman", face="bold"),
        axis.text = element_text(size = 12),
        axis.title.x = element_text(size = 12),
        axis.title.y = element_blank(),
        title = element_text(size = 16),
        legend.title = element_blank(),
        legend.text = element_text(size = 16),
        legend.position = "bottom") +
  guides(color = guide_legend(nrow = 2))

## Low social and high media influence ----
figure_lowhigh_sd <- ggplot() +
  geom_line(data = abm_low_high, aes(x = x_step, y = sd_affective, group = x_run_number), alpha = 0.5, linewidth = 0.3, color = "grey") +
  geom_line(data = low_high_sum, aes(x = x_step, y = mean_sd_affective, group = condition, color = condition), linewidth = 0.8) +
  labs(x = "Steps", y = "AP standard deviation", title = "Low social/High media influences") +
  ylim(c(1,4)) +
  theme_bw() +
  theme(text=element_text(family="Times New Roman", face="bold"),
        axis.text = element_text(size = 12),
        axis.title.x = element_text(size = 12),
        axis.title.y = element_text(size = 16),
        title = element_text(size = 16),
        legend.title = element_blank(),
        legend.text = element_text(size = 16),
        legend.position = "bottom") +
  guides(color = guide_legend(nrow = 2))

## High social and low media influence ----
figure_highlow_sd <- ggplot() +
  geom_line(data = abm_high_low, aes(x = x_step, y = sd_affective, group = x_run_number), alpha = 0.5, linewidth = 0.3, color = "grey") +
  geom_line(data = high_low_sum, aes(x = x_step, y = mean_sd_affective, group = condition, color = condition), linewidth = 0.8) +
  labs(x = "Steps", y = "Affective polarization", title = "High social/Low media influences") +
  ylim(c(1,4)) +
  theme_bw() +
  theme(text=element_text(family="Times New Roman", face="bold"),
        axis.text = element_text(size = 12),
        axis.title.x = element_text(size = 12),
        axis.title.y = element_blank(),
        title = element_text(size = 16),
        legend.title = element_blank(),
        legend.text = element_text(size = 16),
        legend.position = "bottom") +
  guides(color = guide_legend(nrow = 2))

## Combine subgraphs into Figure 3 ----
figure3 <- ggarrange(figure_lowlow_sd, figure_highhigh_sd, figure_lowhigh_sd, figure_highlow_sd,
                     nrow=2, ncol=2, common.legend = TRUE, legend="bottom")


# Figure 4. Social diversity index changes for all agents ----

## Low social and low media influence ----
low_low_diversity <- abm_low_low %>% 
  select(x_run_number, condition, x_step, mean_agent_diversity, mean_media_diversity)
low_low_diversity_sum <- low_low_diversity %>% 
  group_by(x_step, condition) %>%
  summarize(mean_media_diversity = mean(mean_media_diversity),
            mean_agent_diversity = mean(mean_agent_diversity))

figure_lowlow_agent_all <- ggplot() +
  geom_line(data = abm_low_low, aes(x = x_step, y = mean_agent_diversity, group = x_run_number), alpha = 0.5, linewidth = 0.3, color = "grey") +
  geom_line(data = low_low_diversity_sum, aes(x = x_step, y = mean_agent_diversity, group = condition, color = condition), linewidth = 0.8) +
  labs(x = "Steps", y = "Social diversity", title = "Low social/Low media influences") +
  ylim(c(0,0.2)) +
  theme_bw() +
  theme(text=element_text(family="Times New Roman", face="bold"),
        axis.text = element_text(size = 12),
        axis.title.x = element_text(size = 12),
        axis.title.y = element_text(size = 16),
        title = element_text(size = 16),
        legend.title = element_blank(),
        legend.text = element_text(size = 16),
        legend.position = "bottom") +
  guides(color = guide_legend(nrow = 2))

## High social and high media influence ----
high_high_diversity <- abm_high_high %>% 
  select(x_run_number, condition, x_step, mean_agent_diversity, mean_media_diversity)
high_high_diversity_sum <- high_high_diversity %>% 
  group_by(x_step, condition) %>%
  summarize(mean_media_diversity = mean(mean_media_diversity),
            mean_agent_diversity = mean(mean_agent_diversity))

figure_highhigh_agent_all <- ggplot() +
  geom_line(data = abm_high_high, aes(x = x_step, y = mean_agent_diversity, group = x_run_number), alpha = 0.5, linewidth = 0.3, color = "grey") +
  geom_line(data = high_high_diversity_sum, aes(x = x_step, y = mean_agent_diversity, group = condition, color = condition), linewidth = 0.8) +
  labs(x = "Steps", y = "Social diversity", title = "High social/High media influences") +
  ylim(c(0,0.2)) +
  theme_bw() +
  theme(text=element_text(family="Times New Roman", face="bold"),
        axis.text = element_text(size = 12),
        axis.title.x = element_text(size = 12),
        axis.title.y = element_text(size = 16),
        title = element_text(size = 16),
        legend.title = element_blank(),
        legend.text = element_text(size = 16),
        legend.position = "bottom") +
  guides(color = guide_legend(nrow = 2))

## Low social and high media influence ----
low_high_diversity <- abm_low_high %>% 
  select(x_run_number, condition, x_step, mean_agent_diversity, mean_media_diversity)
low_high_diversity_sum <- low_high_diversity %>% 
  group_by(x_step, condition) %>%
  summarize(mean_media_diversity = mean(mean_media_diversity),
            mean_agent_diversity = mean(mean_agent_diversity))

figure_lowhigh_agent_all <- ggplot() +
  geom_line(data = abm_low_high, aes(x = x_step, y = mean_agent_diversity, group = x_run_number), alpha = 0.5, linewidth = 0.3, color = "grey") +
  geom_line(data = low_high_diversity_sum, aes(x = x_step, y = mean_agent_diversity, group = condition, color = condition), linewidth = 0.8) +
  labs(x = "Steps", y = "Social diversity", title = "Low social/High media influences") +
  ylim(c(0,0.2)) +
  theme_bw() +
  theme(text=element_text(family="Times New Roman", face="bold"),
        axis.text = element_text(size = 12),
        axis.title.x = element_text(size = 12),
        axis.title.y = element_text(size = 16),
        title = element_text(size = 16),
        legend.title = element_blank(),
        legend.text = element_text(size = 16),
        legend.position = "bottom") +
  guides(color = guide_legend(nrow = 2))

## High social and low media influence ----
high_low_diversity <- abm_high_low %>% 
  select(x_run_number, condition, x_step, mean_agent_diversity, mean_media_diversity)
high_low_diversity_sum <- high_low_diversity %>% 
  group_by(x_step, condition) %>%
  summarize(mean_media_diversity = mean(mean_media_diversity),
            mean_agent_diversity = mean(mean_agent_diversity))

figure_highlow_agent_all <- ggplot() +
  geom_line(data = abm_high_low, aes(x = x_step, y = mean_agent_diversity, group = x_run_number), alpha = 0.5, linewidth = 0.3, color = "grey") +
  geom_line(data = high_low_diversity_sum, aes(x = x_step, y = mean_agent_diversity, group = condition, color = condition), linewidth = 0.8) +
  labs(x = "Steps", y = "Social diversity", title = "High social/Low media influences") +
  ylim(c(0,0.2)) +
  theme_bw() +
  theme(text=element_text(family="Times New Roman", face="bold"),
        axis.text = element_text(size = 12),
        axis.title.x = element_text(size = 12),
        axis.title.y = element_text(size = 16),
        title = element_text(size = 16),
        legend.title = element_blank(),
        legend.text = element_text(size = 16),
        legend.position = "bottom") +
  guides(color = guide_legend(nrow = 2))

## Combine subgraphs into Figure 4 ----
figure4 <- ggarrange(figure_lowlow_agent_all,figure_highhigh_agent_all, 
                     figure_lowhigh_agent_all, figure_highlow_agent_all,
                     nrow=2, ncol=2, common.legend = TRUE, legend="bottom")


# Figure 5. Media diversity index changes for all agents ----

## Low social and low media influence ----
figure_lowlow_media_all <- ggplot() +
  geom_line(data = abm_low_low, aes(x = x_step, y = mean_media_diversity, group = x_run_number), alpha = 0.5, linewidth = 0.3, color = "grey") +
  geom_line(data = low_low_diversity_sum, aes(x = x_step, y = mean_media_diversity, group = condition, color = condition), linewidth = 0.8) +
  labs(x = "Steps", y = "Media diversity", title = "Low social/Low media influences") +
  ylim(c(0,0.3)) +
  theme_bw() +
  theme(text=element_text(family="Times New Roman", face="bold"),
        axis.text = element_text(size = 12),
        axis.title.x = element_text(size = 12),
        axis.title.y = element_text(size = 16),
        title = element_text(size = 16),
        legend.title = element_blank(),
        legend.text = element_text(size = 16),
        legend.position = "bottom") +
  guides(color = guide_legend(nrow = 2))

## High social and high media influence ----
figure_highhigh_media_all <- ggplot() +
  geom_line(data = abm_high_high, aes(x = x_step, y = mean_media_diversity, group = x_run_number), alpha = 0.5, linewidth = 0.3, color = "grey") +
  geom_line(data = high_high_diversity_sum, aes(x = x_step, y = mean_media_diversity, group = condition, color = condition), linewidth = 0.8) +
  labs(x = "Steps", y = "Media diversity", title = "High social/High media influences") +
  ylim(c(0,0.3)) +
  theme_bw() +
  theme(text=element_text(family="Times New Roman", face="bold"),
        axis.text = element_text(size = 12),
        axis.title.x = element_text(size = 12),
        axis.title.y = element_text(size = 16),
        title = element_text(size = 16),
        legend.title = element_blank(),
        legend.text = element_text(size = 16),
        legend.position = "bottom") +
  guides(color = guide_legend(nrow = 2))

## Low social and high media influence ----
figure_lowhigh_media_all <- ggplot() +
  geom_line(data = abm_low_high, aes(x = x_step, y = mean_media_diversity, group = x_run_number), alpha = 0.5, linewidth = 0.3, color = "grey") +
  geom_line(data = low_high_diversity_sum, aes(x = x_step, y = mean_media_diversity, group = condition, color = condition), linewidth = 0.8) +
  labs(x = "Steps", y = "Media diversity", title = "Low social/High media influences") +
  ylim(c(0,0.3)) +
  theme_bw() +
  theme(text=element_text(family="Times New Roman", face="bold"),
        axis.text = element_text(size = 12),
        axis.title.x = element_text(size = 12),
        axis.title.y = element_text(size = 16),
        title = element_text(size = 16),
        legend.title = element_blank(),
        legend.text = element_text(size = 16),
        legend.position = "bottom") +
  guides(color = guide_legend(nrow = 2))

## High social and low media influence ----
figure_highlow_media_all <- ggplot() +
  geom_line(data = abm_high_low, aes(x = x_step, y = mean_media_diversity, group = x_run_number), alpha = 0.5, linewidth = 0.3, color = "grey") +
  geom_line(data = high_low_diversity_sum, aes(x = x_step, y = mean_media_diversity, group = condition, color = condition), linewidth = 0.8) +
  labs(x = "Steps", y = "Media diversity", title = "High social/Low media influences") +
  ylim(c(0,0.3)) +
  theme_bw() +
  theme(text=element_text(family="Times New Roman", face="bold"),
        axis.text = element_text(size = 12),
        axis.title.x = element_text(size = 12),
        axis.title.y = element_text(size = 16),
        title = element_text(size = 16),
        legend.title = element_blank(),
        legend.text = element_text(size = 16),
        legend.position = "bottom") +
  guides(color = guide_legend(nrow = 2))

## Combine subgraphs into Figure 5 ----
figure5 <- ggarrange(figure_lowlow_media_all,figure_highhigh_media_all, 
                     figure_lowhigh_media_all, figure_highlow_media_all,
                     nrow=2, ncol=2, common.legend = TRUE, legend="bottom")


# Figure 6. Affective polarization differences for partisan agents ----

## Low social and low media influence ----
low_low_affective_partisan <- abm_low_low %>% 
  filter(x_step == 100) %>%
  select(x_run_number, condition, x_step, mean_affective_dem, mean_affective_rep)
low_low_affective_partisan$condition <- factor(low_low_affective_partisan$condition, levels = c("High HD/Low SE rates","Low HD/High SE rates","High HD/High SE rates","Low HD/Low SE rates"))
low_low_affective_sum_parisan <- low_low_affective_partisan %>% 
  group_by(condition) %>%
  summarize(mean_affective_dem = mean(mean_affective_dem),
            mean_affective_rep = mean(mean_affective_rep))

figure_lowlow_affective_diff_partisan_ridge <- ggplot() +
  geom_density_ridges(data = low_low_affective_partisan, 
                      aes(x = mean_affective_dem, y = condition, fill = "Dem"), alpha=0.3, color=NA, scale = 1) +
  geom_density_ridges(data = low_low_affective_partisan, 
                      aes(x = mean_affective_rep, y = condition, fill = "Rep"), alpha=0.3, color=NA, scale = 1) +
  geom_segment(data = low_low_affective_sum_parisan,
               aes(x = mean_affective_dem, xend = mean_affective_dem, 
                   y = as.numeric(condition), 
                   yend = as.numeric(condition) + 1, 
                   color = "Dem"), linewidth = 1, linetype = 2) +
  geom_segment(data = low_low_affective_sum_parisan,
               aes(x = mean_affective_rep, xend = mean_affective_rep, 
                   y = as.numeric(condition), 
                   yend = as.numeric(condition) + 1, 
                   color = "Rep"), linewidth = 1, linetype = 2) +
  xlim(4.5,8.5) +
  labs(title = "Low social/Low media influences", x = "Affective polarization", y = "Density") +
  theme_ridges() +
  theme(text=element_text(family="Times New Roman", face="bold"),
        axis.text = element_text(size = 10),
        axis.title = element_text(size = 12),
        title = element_text(size = 16),
        legend.title = element_blank(),
        legend.text = element_text(size = 16),
        legend.position = "bottom",
        legend.justification = "center",
        legend.box.just = "center") +
  scale_color_manual(name = "Party", values = c("Dem" = "#3182bd", "Rep" = "#F8766D"), label = c("Democrats", "Republicans")) +
  scale_fill_manual(name = "Party", values = c("Dem" = "#3182bd", "Rep" = "#F8766D"), label = c("Democrats", "Republicans"))


## High social and high media influence ----
high_high_affective_partisan <- abm_high_high %>% 
  filter(x_step == 100) %>%
  dplyr::select(x_run_number, condition, x_step, mean_affective_dem, mean_affective_rep)
high_high_affective_partisan$condition <- factor(high_high_affective_partisan$condition, levels = c("High HD/Low SE rates","Low HD/High SE rates","High HD/High SE rates","Low HD/Low SE rates"))
high_high_affective_sum_parisan <- high_high_affective_partisan %>% 
  group_by(condition) %>%
  summarize(mean_affective_dem = mean(mean_affective_dem),
            mean_affective_rep = mean(mean_affective_rep))

figure_highhigh_affective_diff_partisan_ridge <- ggplot() +
  geom_density_ridges(data = high_high_affective_partisan, 
                      aes(x = mean_affective_dem, y = condition, fill = "Dem"), alpha=0.3, color=NA, scale = 1)+
  geom_density_ridges(data = high_high_affective_partisan, 
                      aes(x = mean_affective_rep, y = condition, fill = "Rep"), alpha=0.3, color=NA, scale = 1)+
  geom_segment(data = high_high_affective_sum_parisan,
               aes(x = mean_affective_dem, xend = mean_affective_dem, 
                   y = as.numeric(condition), 
                   yend = as.numeric(condition) + 1, 
                   color = "Dem"), linewidth = 1, linetype = 2) +
  geom_segment(data = high_high_affective_sum_parisan,
               aes(x = mean_affective_rep, xend = mean_affective_rep, 
                   y = as.numeric(condition), 
                   yend = as.numeric(condition) + 1, 
                   color = "Rep"), linewidth = 1, linetype = 2) +
  xlim(4.5,8.5) +
  labs(title = "High social/High media influences", x = "Affective polarization", y = "Density") +
  theme_ridges() +
  theme(text=element_text(family="Times New Roman", face="bold"),
        axis.text = element_text(size = 10),
        axis.title = element_text(size = 12),
        title = element_text(size = 16),
        legend.title = element_blank(),
        legend.text = element_text(size = 16),
        legend.position = "bottom",
        legend.justification = "center",
        legend.box.just = "center") +
  scale_color_manual(name = "Party", values = c("Dem" = "#3182bd", "Rep" = "#F8766D"), label = c("Democrats", "Republicans")) +
  scale_fill_manual(name = "Party", values = c("Dem" = "#3182bd", "Rep" = "#F8766D"), label = c("Democrats", "Republicans"))


## Low social and high media influence ----
low_high_affective_partisan <- abm_low_high %>% 
  filter(x_step == 100) %>%
  select(x_run_number, condition, x_step, mean_affective_dem, mean_affective_rep)
low_high_affective_partisan$condition <- factor(low_high_affective_partisan$condition, levels = c("High HD/Low SE rates","Low HD/High SE rates","High HD/High SE rates","Low HD/Low SE rates"))
low_high_affective_sum_parisan <- low_high_affective_partisan %>% 
  group_by(condition) %>%
  summarize(mean_affective_dem = mean(mean_affective_dem),
            mean_affective_rep = mean(mean_affective_rep))

figure_lowhigh_affective_diff_partisan_ridge <- ggplot() +
  geom_density_ridges(data = low_high_affective_partisan, 
                      aes(x = mean_affective_dem, y = condition, fill = "Dem"), alpha=0.3, color=NA, scale = 1)+
  geom_density_ridges(data = low_high_affective_partisan, 
                      aes(x = mean_affective_rep, y = condition, fill = "Rep"), alpha=0.3, color=NA, scale = 1)+
  geom_segment(data = low_high_affective_sum_parisan,
               aes(x = mean_affective_dem, xend = mean_affective_dem, 
                   y = as.numeric(condition), 
                   yend = as.numeric(condition) + 1, 
                   color = "Dem"), linewidth = 1, linetype = 2) +
  geom_segment(data = low_high_affective_sum_parisan,
               aes(x = mean_affective_rep, xend = mean_affective_rep, 
                   y = as.numeric(condition), 
                   yend = as.numeric(condition) + 1, 
                   color = "Rep"), linewidth = 1, linetype = 2) +
  xlim(4.5,8.5) +
  labs(title = "Low social/High media influences", x = "Affective polarization", y = "Density") +
  theme_ridges() +
  theme(text=element_text(family="Times New Roman", face="bold"),
        axis.text = element_text(size = 10),
        axis.title = element_text(size = 12),
        legend.title = element_blank(),
        legend.text = element_text(size = 16),
        legend.position = "bottom",
        legend.justification = "center",
        legend.box.just = "center") +
  scale_color_manual(name = "Party", values = c("Dem" = "#3182bd", "Rep" = "#F8766D"), label = c("Democrats", "Republicans")) +
  scale_fill_manual(name = "Party", values = c("Dem" = "#3182bd", "Rep" = "#F8766D"), label = c("Democrats", "Republicans"))

## High social and low media influence ----
high_low_affective_partisan <- abm_high_low %>% 
  filter(x_step == 100) %>%
  dplyr::select(x_run_number, condition, x_step, mean_affective_dem, mean_affective_rep)
high_low_affective_partisan$condition <- factor(high_low_affective_partisan$condition, levels = c("High HD/Low SE rates","Low HD/High SE rates","High HD/High SE rates","Low HD/Low SE rates"))
high_low_affective_sum_parisan <- high_low_affective_partisan %>% 
  group_by(condition) %>%
  summarize(mean_affective_dem = mean(mean_affective_dem),
            mean_affective_rep = mean(mean_affective_rep))

figure_highlow_affective_diff_partisan_ridge <- ggplot() +
  geom_density_ridges(data = high_low_affective_partisan, 
                      aes(x = mean_affective_dem, y = condition, fill = "Dem"), alpha=0.3, color=NA, scale = 1)+
  geom_density_ridges(data = high_low_affective_partisan, 
                      aes(x = mean_affective_rep, y = condition, fill = "Rep"), alpha=0.3, color=NA, scale = 1)+
  geom_segment(data = high_low_affective_sum_parisan,
               aes(x = mean_affective_dem, xend = mean_affective_dem, 
                   y = as.numeric(condition), 
                   yend = as.numeric(condition) + 1, 
                   color = "Dem"), linewidth = 1, linetype = 2) +
  geom_segment(data = high_low_affective_sum_parisan,
               aes(x = mean_affective_rep, xend = mean_affective_rep, 
                   y = as.numeric(condition), 
                   yend = as.numeric(condition) + 1, 
                   color = "Rep"), linewidth = 1, linetype = 2) +
  xlim(4.5,8.5) +
  labs(title = "High social/Low media influences", x = "Affective polarization", y = "Density") +
  theme_ridges() +
  theme(text=element_text(family="Times New Roman", face="bold"),
        axis.text = element_text(size = 10),
        axis.title = element_text(size = 12),
        legend.title = element_blank(),
        legend.text = element_text(size = 16),
        legend.position = "bottom",
        legend.justification = "center",
        legend.box.just = "center") +
  scale_color_manual(name = "Party", values = c("Dem" = "#3182bd", "Rep" = "#F8766D"), label = c("Democrats", "Republicans")) +
  scale_fill_manual(name = "Party", values = c("Dem" = "#3182bd", "Rep" = "#F8766D"), label = c("Democrats", "Republicans"))

## Combine subgraphs into Figure 6 ----
figure6 <- ggarrange(figure_lowlow_affective_diff_partisan_ridge, figure_highhigh_affective_diff_partisan_ridge, 
                     figure_lowhigh_affective_diff_partisan_ridge, figure_highlow_affective_diff_partisan_ridge,
                     nrow=2, ncol=2,font.label = list(color = "black", face = "bold", family = "Times New Roman"),
                     common.legend = TRUE, legend="bottom")


# Figure 7. Social diversity index for partisan agents at final step of simulations ----

## Low social and low media influence ----
low_low_diversity_partisan <- abm_low_low %>% 
  filter(x_step == 100) %>%
  select(x_run_number, condition, x_step, mean_agent_diversity_dem, mean_media_diversity_dem, mean_agent_diversity_rep, mean_media_diversity_rep)
low_low_diversity_partisan$condition <- factor(low_low_diversity_partisan$condition, levels = c("High HD/Low SE rates","Low HD/High SE rates","High HD/High SE rates","Low HD/Low SE rates"))
low_low_diversity_sum_parisan <- low_low_diversity_partisan %>% 
  group_by(condition) %>%
  summarize(mean_media_dem = mean(mean_media_diversity_dem),
            mean_media_rep = mean(mean_media_diversity_rep),
            mean_agent_dem = mean(mean_agent_diversity_dem),
            mean_agent_rep = mean(mean_agent_diversity_rep))

figure_lowlow_agent_diff_partisan_ridge <- ggplot() +
  geom_density_ridges(data = low_low_diversity_partisan, 
                      aes(x = mean_agent_diversity_dem, y = condition, fill = "Dem"), alpha=0.3, color=NA, scale = 1)+
  geom_density_ridges(data = low_low_diversity_partisan, 
                      aes(x = mean_agent_diversity_rep, y = condition, fill = "Rep"), alpha=0.3, color=NA, scale = 1)+
  geom_segment(data = low_low_diversity_sum_parisan, 
               aes(x = mean_agent_dem, xend = mean_agent_dem, 
                   y = as.numeric(condition), 
                   yend = as.numeric(condition) + 1, 
                   color = "Dem"), linewidth = 1, linetype = 2) +
  geom_segment(data = low_low_diversity_sum_parisan, 
               aes(x = mean_agent_rep, xend = mean_agent_rep, 
                   y = as.numeric(condition), 
                   yend = as.numeric(condition) + 1, 
                   color = "Rep"), linewidth = 1, linetype = 2) +
  xlim(-0.02,0.18) +
  labs(title = "Low social/Low media influences", x = "Social diversity index", y = "Density") +
  theme_ridges() +
  theme(text=element_text(family="Times New Roman", face="bold"),
        axis.text = element_text(size = 10),
        axis.title = element_text(size = 12),
        title = element_text(size = 16),
        legend.title = element_blank(),
        legend.text = element_text(size = 16),
        legend.position = "bottom",
        legend.justification = "center",
        legend.box.just = "center") +
  scale_color_manual(name = "Party", values = c("Dem" = "#3182bd", "Rep" = "#F8766D"), label = c("Democrats", "Republicans")) +
  scale_fill_manual(name = "Party", values = c("Dem" = "#3182bd", "Rep" = "#F8766D"), label = c("Democrats", "Republicans"))


## High social and high media influence ----
high_high_diversity_partisan <- abm_high_high %>% 
  filter(x_step == 100) %>%
  select(x_run_number, condition, x_step, mean_agent_diversity_dem, mean_media_diversity_dem, mean_agent_diversity_rep, mean_media_diversity_rep)
high_high_diversity_partisan$condition <- factor(high_high_diversity_partisan$condition, levels = c("High HD/Low SE rates","Low HD/High SE rates","High HD/High SE rates","Low HD/Low SE rates"))
high_high_diversity_sum_parisan <- high_high_diversity_partisan %>% 
  group_by(condition) %>%
  summarize(mean_media_dem = mean(mean_media_diversity_dem),
            mean_media_rep = mean(mean_media_diversity_rep),
            mean_agent_dem = mean(mean_agent_diversity_dem),
            mean_agent_rep = mean(mean_agent_diversity_rep))

figure_highhigh_agent_diff_partisan_ridge <- ggplot() +
  geom_density_ridges(data = high_high_diversity_partisan, 
                      aes(x = mean_agent_diversity_dem, y = condition, fill = "Dem"), alpha=0.3, color=NA, scale = 1)+
  geom_density_ridges(data = high_high_diversity_partisan, 
                      aes(x = mean_agent_diversity_rep, y = condition, fill = "Rep"), alpha=0.3, color=NA, scale = 1)+
  geom_segment(data = high_high_diversity_sum_parisan, 
               aes(x = mean_agent_dem, xend = mean_agent_dem, 
                   y = as.numeric(condition), 
                   yend = as.numeric(condition) + 1, 
                   color = "Dem"), linewidth = 1, linetype = 2) +
  geom_segment(data = high_high_diversity_sum_parisan, 
               aes(x = mean_agent_rep, xend = mean_agent_rep, 
                   y = as.numeric(condition), 
                   yend = as.numeric(condition) + 1, 
                   color = "Rep"), linewidth = 1, linetype = 2) +
  xlim(-0.02,0.18) +
  labs(title = "High social/High media influences", x = "Social diversity index", y = "Density") +
  theme_ridges() +
  theme(text=element_text(family="Times New Roman", face="bold"),
        axis.text = element_text(size = 10),
        axis.title = element_text(size = 12),
        title = element_text(size = 16),
        llegend.title = element_blank(),
        legend.text = element_text(size = 16),
        legend.position = "bottom",
        legend.justification = "center",
        legend.box.just = "center") +
  scale_color_manual(name = "Party", values = c("Dem" = "#3182bd", "Rep" = "#F8766D"), label = c("Democrats", "Republicans")) +
  scale_fill_manual(name = "Party", values = c("Dem" = "#3182bd", "Rep" = "#F8766D"), label = c("Democrats", "Republicans"))


## Low social and high media influence ----
low_high_diversity_partisan <- abm_low_high %>% 
  filter(x_step == 100) %>%
  dplyr::select(x_run_number, condition, x_step, mean_agent_diversity_dem, mean_media_diversity_dem, mean_agent_diversity_rep, mean_media_diversity_rep)
low_high_diversity_partisan$condition <- factor(low_high_diversity_partisan$condition, levels = c("High HD/Low SE rates","Low HD/High SE rates","High HD/High SE rates","Low HD/Low SE rates"))
low_high_diversity_sum_parisan <- low_high_diversity_partisan %>% 
  group_by(condition) %>%
  summarize(mean_media_dem = mean(mean_media_diversity_dem),
            mean_media_rep = mean(mean_media_diversity_rep),
            mean_agent_dem = mean(mean_agent_diversity_dem),
            mean_agent_rep = mean(mean_agent_diversity_rep))

figure_lowhigh_agent_diff_partisan_ridge <- ggplot() +
  geom_density_ridges(data = low_high_diversity_partisan, 
                      aes(x = mean_agent_diversity_dem, y = condition, fill = "Dem"), alpha=0.3, color=NA, scale = 1)+
  geom_density_ridges(data = low_high_diversity_partisan, 
                      aes(x = mean_agent_diversity_rep, y = condition, fill = "Rep"), alpha=0.3, color=NA, scale = 1)+
  geom_segment(data = low_high_diversity_sum_parisan, 
               aes(x = mean_agent_dem, xend = mean_agent_dem, 
                   y = as.numeric(condition), 
                   yend = as.numeric(condition) + 1, 
                   color = "Dem"), linewidth = 1, linetype = 2) +
  geom_segment(data = low_high_diversity_sum_parisan, 
               aes(x = mean_agent_rep, xend = mean_agent_rep, 
                   y = as.numeric(condition), 
                   yend = as.numeric(condition) + 1, 
                   color = "Rep"), linewidth = 1, linetype = 2) +
  xlim(-0.02,0.18) +
  labs(title = "Low social/High media influences", x = "Social diversity index", y = "Density") +
  theme_ridges() +
  theme(text=element_text(family="Times New Roman", face="bold"),
        axis.text = element_text(size = 10),
        axis.title = element_text(size = 12),
        title = element_text(size = 16),
        legend.title = element_blank(),
        legend.text = element_text(size = 16),
        legend.position = "bottom",
        legend.justification = "center",
        legend.box.just = "center") +
  scale_color_manual(name = "Party", values = c("Dem" = "#3182bd", "Rep" = "#F8766D"), label = c("Democrats", "Republicans")) +
  scale_fill_manual(name = "Party", values = c("Dem" = "#3182bd", "Rep" = "#F8766D"), label = c("Democrats", "Republicans"))


## High social and low media influence ----
high_low_diversity_partisan <- abm_high_low %>% 
  filter(x_step == 100) %>%
  dplyr::select(x_run_number, condition, x_step, mean_agent_diversity_dem, mean_media_diversity_dem, mean_agent_diversity_rep, mean_media_diversity_rep)
high_low_diversity_partisan$condition <- factor(high_low_diversity_partisan$condition, levels = c("High HD/Low SE rates","Low HD/High SE rates","High HD/High SE rates","Low HD/Low SE rates"))
high_low_diversity_sum_parisan <- high_low_diversity_partisan %>% 
  group_by(condition) %>%
  summarize(mean_media_dem = mean(mean_media_diversity_dem),
            mean_media_rep = mean(mean_media_diversity_rep),
            mean_agent_dem = mean(mean_agent_diversity_dem),
            mean_agent_rep = mean(mean_agent_diversity_rep))

figure_highlow_agent_diff_partisan_ridge <- ggplot() +
  geom_density_ridges(data = high_low_diversity_partisan, 
                      aes(x = mean_agent_diversity_dem, y = condition, fill = "Dem"), alpha=0.3, color=NA, scale = 1)+
  geom_density_ridges(data = high_low_diversity_partisan, 
                      aes(x = mean_agent_diversity_rep, y = condition, fill = "Rep"), alpha=0.3, color=NA, scale = 1)+
  geom_segment(data = high_low_diversity_sum_parisan, 
               aes(x = mean_agent_dem, xend = mean_agent_dem, 
                   y = as.numeric(condition), 
                   yend = as.numeric(condition) + 1, 
                   color = "Dem"), linewidth = 1, linetype = 2) +
  geom_segment(data = high_low_diversity_sum_parisan, 
               aes(x = mean_agent_rep, xend = mean_agent_rep, 
                   y = as.numeric(condition), 
                   yend = as.numeric(condition) + 1, 
                   color = "Rep"), linewidth = 1, linetype = 2) +
  xlim(-0.02,0.18) +
  labs(title = "High social/Low media influences", x = "Social diversity index", y = "Density") +
  theme_ridges() +
  theme(text=element_text(family="Times New Roman", face="bold"),
        axis.text = element_text(size = 10),
        axis.title = element_text(size = 12),
        title = element_text(size = 16),
        legend.title = element_blank(),
        legend.text = element_text(size = 16),
        legend.position = "bottom",
        legend.justification = "center",
        legend.box.just = "center") +
  scale_color_manual(name = "Party", values = c("Dem" = "#3182bd", "Rep" = "#F8766D"), label = c("Democrats", "Republicans")) +
  scale_fill_manual(name = "Party", values = c("Dem" = "#3182bd", "Rep" = "#F8766D"), label = c("Democrats", "Republicans"))


## Combine subgraphs into Figure 7 ----
figure7 <- ggarrange(figure_lowlow_agent_diff_partisan_ridge,figure_highhigh_agent_diff_partisan_ridge,  
                     figure_lowhigh_agent_diff_partisan_ridge, figure_highlow_agent_diff_partisan_ridge, 
                     nrow=2, ncol=2, font.label = list(color = "black", face = "bold", family = "Times New Roman"),
                     common.legend = TRUE, legend="bottom")



# Figure 8. Media diversity index for partisan agents at final step of simulations ----

## Low social and low media influence ----
figure_lowlow_media_diff_partisan_ridge <- ggplot() +
  geom_density_ridges(data = low_low_diversity_partisan, 
                      aes(x = mean_media_diversity_dem, y = condition, fill = "Dem"), alpha=0.3, color=NA, scale = 1)+
  geom_density_ridges(data = low_low_diversity_partisan, 
                      aes(x = mean_media_diversity_rep, y = condition, fill = "Rep"), alpha=0.3, color=NA, scale = 1)+
  geom_segment(data = low_low_diversity_sum_parisan, 
               aes(x = mean_media_dem, xend = mean_media_dem, 
                   y = as.numeric(condition), 
                   yend = as.numeric(condition) + 1, 
                   color = "Dem"), linewidth = 1, linetype = 2) +
  geom_segment(data = low_low_diversity_sum_parisan, 
               aes(x = mean_media_rep, xend = mean_media_rep, 
                   y = as.numeric(condition), 
                   yend = as.numeric(condition) + 1, 
                   color = "Rep"), linewidth = 1, linetype = 2) +
  xlim(0,0.25) +
  labs(title = "Low social/Low media influences", x = "Media diversity index", y = "Density") +
  theme_ridges() +
  theme(text=element_text(family="Times New Roman", face="bold"),
        axis.text = element_text(size = 10),
        axis.title = element_text(size = 12),
        title = element_text(size = 16),
        legend.title = element_blank(),
        legend.text = element_text(size = 16),
        legend.position = "bottom",
        legend.justification = "center",
        legend.box.just = "center") +
  scale_color_manual(name = "Party", values = c("Dem" = "#3182bd", "Rep" = "#F8766D"), label = c("Democrats", "Republicans")) +
  scale_fill_manual(name = "Party", values = c("Dem" = "#3182bd", "Rep" = "#F8766D"), label = c("Democrats", "Republicans"))


## High social and high media influence ----
figure_highhigh_media_diff_partisan_ridge <- ggplot() +
  geom_density_ridges(data = high_high_diversity_partisan, 
                      aes(x = mean_media_diversity_dem, y = condition, fill = "Dem"), alpha=0.3, color=NA, scale = 1)+
  geom_density_ridges(data = high_high_diversity_partisan, 
                      aes(x = mean_media_diversity_rep, y = condition, fill = "Rep"), alpha=0.3, color=NA, scale = 1)+
  geom_segment(data = high_high_diversity_sum_parisan, 
               aes(x = mean_media_dem, xend = mean_media_dem, 
                   y = as.numeric(condition), 
                   yend = as.numeric(condition) + 1, 
                   color = "Dem"), linewidth = 1, linetype = 2) +
  geom_segment(data = high_high_diversity_sum_parisan, 
               aes(x = mean_media_rep, xend = mean_media_rep, 
                   y = as.numeric(condition), 
                   yend = as.numeric(condition) + 1, 
                   color = "Rep"), linewidth = 1, linetype = 2) +
  xlim(0,0.25) +
  labs(title = "High social/High media influences", x = "Media diversity index", y = "Density") +
  theme_ridges() +
  theme(text=element_text(family="Times New Roman", face="bold"),
        axis.text = element_text(size = 10),
        axis.title = element_text(size = 12),
        title = element_text(size = 16),
        legend.title = element_blank(),
        legend.text = element_text(size = 16),
        legend.position = "bottom",
        legend.justification = "center",
        legend.box.just = "center") +
  scale_color_manual(name = "Party", values = c("Dem" = "#3182bd", "Rep" = "#F8766D"), label = c("Democrats", "Republicans")) +
  scale_fill_manual(name = "Party", values = c("Dem" = "#3182bd", "Rep" = "#F8766D"), label = c("Democrats", "Republicans"))


## Low social and high media influence ----
figure_lowhigh_media_diff_partisan_ridge <- ggplot() +
  geom_density_ridges(data = low_high_diversity_partisan, 
                      aes(x = mean_media_diversity_dem, y = condition, fill = "Dem"), alpha=0.3, color=NA, scale = 1)+
  geom_density_ridges(data = low_high_diversity_partisan, 
                      aes(x = mean_media_diversity_rep, y = condition, fill = "Rep"), alpha=0.3, color=NA, scale = 1)+
  geom_segment(data = low_high_diversity_sum_parisan, 
               aes(x = mean_media_dem, xend = mean_media_dem, 
                   y = as.numeric(condition), 
                   yend = as.numeric(condition) + 1, 
                   color = "Dem"), linewidth = 1, linetype = 2) +
  geom_segment(data = low_high_diversity_sum_parisan, 
               aes(x = mean_media_rep, xend = mean_media_rep, 
                   y = as.numeric(condition), 
                   yend = as.numeric(condition) + 1, 
                   color = "Rep"), linewidth = 1, linetype = 2) +
  xlim(0,0.25) +
  labs(title = "Low social/High media influences", x = "Media diversity index", y = "Density") +
  theme_ridges() +
  theme(text=element_text(family="Times New Roman", face="bold"),
        axis.text = element_text(size = 10),
        axis.title = element_text(size = 12),
        title = element_text(size = 16),
        legend.title = element_blank(),
        legend.text = element_text(size = 16),
        legend.position = "bottom",
        legend.justification = "center",
        legend.box.just = "center") +
  scale_color_manual(name = "Party", values = c("Dem" = "#3182bd", "Rep" = "#F8766D"), label = c("Democrats", "Republicans")) +
  scale_fill_manual(name = "Party", values = c("Dem" = "#3182bd", "Rep" = "#F8766D"), label = c("Democrats", "Republicans"))


## High social and low media influence ----
figure_highlow_media_diff_partisan_ridge <- ggplot() +
  geom_density_ridges(data = high_low_diversity_partisan, 
                      aes(x = mean_media_diversity_dem, y = condition, fill = "Dem"), alpha=0.3, color=NA, scale = 1)+
  geom_density_ridges(data = high_low_diversity_partisan, 
                      aes(x = mean_media_diversity_rep, y = condition, fill = "Rep"), alpha=0.3, color=NA, scale = 1)+
  geom_segment(data = high_low_diversity_sum_parisan, 
               aes(x = mean_media_dem, xend = mean_media_dem, 
                   y = as.numeric(condition), 
                   yend = as.numeric(condition) + 1, 
                   color = "Dem"), linewidth = 1, linetype = 2) +
  geom_segment(data = high_low_diversity_sum_parisan, 
               aes(x = mean_media_rep, xend = mean_media_rep, 
                   y = as.numeric(condition), 
                   yend = as.numeric(condition) + 1, 
                   color = "Rep"), linewidth = 1, linetype = 2) +
  xlim(0,0.25) +
  labs(title = "High social/Low media influences", x = "Media diversity index", y = "Density") +
  theme_ridges() +
  theme(text=element_text(family="Times New Roman", face="bold"),
        axis.text = element_text(size = 10),
        axis.title = element_text(size = 12),
        title = element_text(size = 16),
        llegend.title = element_blank(),
        legend.text = element_text(size = 16),
        legend.position = "bottom",
        legend.justification = "center",
        legend.box.just = "center") +
  scale_color_manual(name = "Party", values = c("Dem" = "#3182bd", "Rep" = "#F8766D"), label = c("Democrats", "Republicans")) +
  scale_fill_manual(name = "Party", values = c("Dem" = "#3182bd", "Rep" = "#F8766D"), label = c("Democrats", "Republicans"))


## Combine subgraphs into Figure 8 ----
figure8 <- ggarrange(figure_lowlow_media_diff_partisan_ridge,figure_highhigh_media_diff_partisan_ridge,  
                     figure_lowhigh_media_diff_partisan_ridge, figure_highlow_media_diff_partisan_ridge, 
                     nrow=2, ncol=2, font.label = list(color = "black", face = "bold", family = "Times New Roman"),
                     common.legend = TRUE, legend="bottom")


