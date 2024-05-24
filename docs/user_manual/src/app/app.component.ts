import {ChangeDetectorRef, Component, OnDestroy, ViewChild} from '@angular/core';
import {RouterOutlet} from '@angular/router';
import {MatToolbar} from "@angular/material/toolbar";
import {MatDrawerMode, MatSidenav, MatSidenavModule} from "@angular/material/sidenav";
import {MatButton, MatIconButton} from "@angular/material/button";
import {MatIcon} from "@angular/material/icon";
import {TocComponent} from "./toc/toc.component";
import {MediaMatcher} from "@angular/cdk/layout";
import {Title} from "@angular/platform-browser";
import {ImageOutletComponent} from "./image-viewer/image-outlet/image-outlet.component";

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [RouterOutlet, MatToolbar, MatIconButton, MatIcon, MatButton, TocComponent, MatSidenavModule, ImageOutletComponent],
  templateUrl: './app.component.html',
  styleUrl: './app.component.scss'
})
export class AppComponent implements OnDestroy {
  private mobileQuery: MediaQueryList;

  private readonly _mobileQueryListener: () => void;

  @ViewChild('sidenav')
  sideNav?: MatSidenav

  constructor(changeDetectorRef: ChangeDetectorRef,
              media: MediaMatcher,
              title: Title) {
    this.mobileQuery = media.matchMedia('(max-width: 600px)');
    this._mobileQueryListener = () => changeDetectorRef.detectChanges();
    this.mobileQuery.addEventListener('change', this._mobileQueryListener);

    title.setTitle($localize `Battery Alarm User's Guide`)
  }

  ngOnDestroy(): void {
    this.mobileQuery.removeEventListener('change', this._mobileQueryListener);
  }

  protected get isMobile(): boolean {
    return this.mobileQuery.matches
  }

  protected get sideNavMode(): MatDrawerMode {
    return this.isMobile ? 'over' : 'side'
  }

  protected onSideNavClick() {
    if (this.isMobile) {
      this.sideNav?.close()
    }
  }
}
