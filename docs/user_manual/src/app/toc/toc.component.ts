import {Component} from '@angular/core';
import {MatListItem, MatListItemIcon, MatListItemTitle, MatNavList} from "@angular/material/list";
import {RouterLink, RouterLinkActive} from "@angular/router";
import {MatIcon} from "@angular/material/icon";

@Component({
  selector: 'app-toc',
  standalone: true,
  imports: [
    MatListItem,
    MatNavList,
    RouterLink,
    RouterLinkActive,
    MatIcon,
    MatListItemTitle,
    MatListItemIcon,
  ],
  templateUrl: './toc.component.html',
  styleUrl: './toc.component.scss'
})
export class TocComponent {
  protected readonly routes: TocRoute[] = [
    {
      title: $localize `Introduction`,
      link: '/introduction',
      icon: 'waving_hand',
    },
    {
      title: $localize `Operation`,
      link: '/operation',
      icon: 'sports_esports',
    },
    {
      title: $localize `Installation`,
      link: '/installation',
      icon: 'construction',
    },
    {
      title: $localize `Configuration`,
      link: '/configuration',
      icon: 'settings',
    },
  ]
}

interface TocRoute {
  title: string
  link: string
  icon: string
  active?: boolean
}
