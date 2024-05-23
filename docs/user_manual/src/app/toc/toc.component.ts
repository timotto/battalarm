import {Component} from '@angular/core';
import {MatListItem, MatNavList} from "@angular/material/list";
import {ActivatedRoute, RouterLink, RouterLinkActive, UrlSegment} from "@angular/router";

@Component({
  selector: 'app-toc',
  standalone: true,
  imports: [
    MatListItem,
    MatNavList,
    RouterLink,
    RouterLinkActive,
  ],
  templateUrl: './toc.component.html',
  styleUrl: './toc.component.scss'
})
export class TocComponent {
  constructor(route: ActivatedRoute) {
    route.url.subscribe(urlSegment => this.onRouteChange(urlSegment))
  }

  protected readonly routes: TocRoute[] = [
    {
      title: $localize `Introduction`,
      link: '/introduction',
    },
    {
      title: $localize `Operation`,
      link: '/operation',
    },
    {
      title: $localize `Installation`,
      link: '/installation',
    },
    {
      title: $localize `Configuration`,
      link: '/configuration',
    },
  ]

  private onRouteChange(urlSegment: UrlSegment[]) {
    console.log('on route change', urlSegment)
  }
}

interface TocRoute {
  title: string
  link: string
  active?: boolean
}
