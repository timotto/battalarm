import { Component } from '@angular/core';
import {RouterLink} from "@angular/router";
import {VideoComponent} from "../video/video.component";

@Component({
  selector: 'app-chapter-operation',
  standalone: true,
  imports: [
    RouterLink,
    VideoComponent,
  ],
  templateUrl: './chapter-operation.component.html',
  styleUrl: './chapter-operation.component.scss'
})
export class ChapterOperationComponent {

}
