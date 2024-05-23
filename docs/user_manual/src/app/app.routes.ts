import { Routes } from '@angular/router';
import {ChapterIntroductionComponent} from "./chapter-introduction/chapter-introduction.component";
import {ChapterOperationComponent} from "./chapter-operation/chapter-operation.component";
import {ChapterInstallationComponent} from "./chapter-installation/chapter-installation.component";
import {ChapterConfigurationComponent} from "./chapter-configuration/chapter-configuration.component";

export const routes: Routes = [
  {
    path: "",
    pathMatch: "full",
    component: ChapterIntroductionComponent,
  },
  {
    path: "introduction",
    component: ChapterIntroductionComponent
  },
  {
    path: "operation",
    component: ChapterOperationComponent,
  },
  {
    path: "installation",
    component: ChapterInstallationComponent,
  },
  {
    path: "configuration",
    component: ChapterConfigurationComponent,
  }
];
