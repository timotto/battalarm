import {ChangeDetectorRef, Component, OnDestroy} from '@angular/core';
import {MediaMatcher} from "@angular/cdk/layout";
import {ImageThumbnailComponent} from "../image-viewer/image-thumbnail/image-thumbnail.component";

@Component({
  selector: 'app-chapter-installation',
  standalone: true,
  imports: [
    ImageThumbnailComponent,
  ],
  templateUrl: './chapter-installation.component.html',
  styleUrl: './chapter-installation.component.scss'
})
export class ChapterInstallationComponent implements OnDestroy {
  mobileQuery: MediaQueryList;

  private readonly _mobileQueryListener: () => void;

  constructor(changeDetectorRef: ChangeDetectorRef, media: MediaMatcher) {
    this.mobileQuery = media.matchMedia('(max-width: 600px)');
    this._mobileQueryListener = () => changeDetectorRef.detectChanges();
    this.mobileQuery.addEventListener('change', this._mobileQueryListener);
  }

  protected get imageClass(): string {
    return this.mobileQuery.matches ? 'mobile-image' : 'float-left-image'
  }

  ngOnDestroy(): void {
    this.mobileQuery.removeEventListener('change', this._mobileQueryListener);
  }
}
