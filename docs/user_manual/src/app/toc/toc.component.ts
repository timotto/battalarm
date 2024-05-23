import {Component} from '@angular/core';
import {MatListItem, MatNavList} from "@angular/material/list";
import {RouterLink} from "@angular/router";

@Component({
  selector: 'app-toc',
  standalone: true,
  imports: [
    MatListItem,
    MatNavList,
    RouterLink,
  ],
  templateUrl: './toc.component.html',
  styleUrl: './toc.component.scss'
})
export class TocComponent {
}
