import { Component } from '@angular/core';
import {RouterLink} from "@angular/router";
import {MatList, MatListItem, MatNavList} from "@angular/material/list";

@Component({
  selector: 'app-chapter-introduction',
  standalone: true,
  imports: [
    RouterLink,
    MatList,
    MatListItem,
    MatNavList
  ],
  templateUrl: './chapter-introduction.component.html',
  styleUrl: './chapter-introduction.component.scss'
})
export class ChapterIntroductionComponent {

}
